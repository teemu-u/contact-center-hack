import os
import time
import json
import urllib.request
import streamlit as st
from random import random
import azure.cognitiveservices.speech as speechsdk
from dotenv import load_dotenv, find_dotenv
import ssl
import uuid
from azure.cosmos import CosmosClient

#################################################################################
# HELPER FUNCTIONS
#################################################################################
def allowSelfSignedHttps(allowed):
    # bypass the server certificate verification on client side
    if allowed and not os.environ.get('PYTHONHTTPSVERIFY', '') and getattr(ssl, '_create_unverified_context', None):
        ssl._create_default_https_context = ssl._create_unverified_context

def init_session_state(call_id:str):
    """
    Initialize session state for the app
    
    Args:
    call_id : str : the call_id selected by the user
    
    Returns:
    None
    """
    call_context['nextBestAction'] = [None]
    call_context['customerIdentified'] = None
    call_context['sellingOpportunity'] = None
    call_context['sentiment'] = None
    call_context['all_recognized'] = []
    call_context['audio_path'] = os.path.join("Call Samples","Audio",call_id+".wav")
    call_context['printable_text'] = ""
    call_context['call_uuid'] = str(uuid.uuid4())

def handle_printable_text(evt):
    """
    Handle the printable text event.

    Args:
        evt (Event): The event object containing the result text.

    Returns:
        None

    Raises:
        None
    """
    if evt.result.text != "":
        new_line = "\n\n"
        call_context['printable_text'] = f"{new_line.join(call_context['all_recognized'])}{new_line}{evt.result.text}"

def register_transcript(evt):
    """
    Register the transcript from an event.

    Args:
        evt (Event): The event containing the transcript.

    Returns:
        None
    """
    if evt.result.text != "":
        call_context['all_recognized'].append(evt.result.text)

def customer_identification(customer_ident):
    if customer_ident['identified']:
        ids = list({ele for ele in customer_ident if customer_ident[ele]})
        all_text = ""
        for id in ids:
            if id != 'identified':
                all_text += f"{id}: {customer_ident[id]}\n"

        return all_text
    else:
        return None
    
def call_analysis(evt):
    """
    Perform call analysis on the event.

    Args:
        evt (Event): The event containing the transcript.

    Returns:
        None
    """
    data = {"transcript": '\n'.join(call_context['all_recognized'])}
    body = str.encode(json.dumps(data))
    headers = {'Content-Type':'application/json', 'Authorization':('Bearer ' + PROMPTFLOW_DEPLOYMENT_KEY)}

    req = urllib.request.Request(PROMPTFLOW_DEPLOYMENT_URL, body, headers)

    try:
        response = urllib.request.urlopen(req)
        response_data = json.loads(response.read().decode('utf-8'))

        call_context['nextBestAction'].append(response_data.get('nextBestAction'))
        call_context['sellingOpportunity'] = response_data.get('sellingOpportunity')
        call_context['sentiment'] = response_data.get('sentiment')
        if 'customerIdentified' in response_data:
            if isinstance(response_data['customerIdentified'], str):
                call_context['customerIdentified'] = json.loads(response_data['customerIdentified'])
            elif isinstance(response_data['customerIdentified'], dict):
                call_context['customerIdentified'] = response_data['customerIdentified']

    except urllib.error.HTTPError as error:
        print("The request failed with status code: " + str(error.code))
        # Print the headers - they include the requert ID and the timestamp, which are useful for debugging the failure
        print(error.info())
        print(error.read().decode("utf8", 'ignore'))

def saveCall():
    """
    Save call context variables to CosmosDB.

    Returns:
        None
    """
    data = {
        "id": call_context['call_uuid'],
        "transcript": call_context['all_recognized'],
        "actions_recommended": call_context['nextBestAction'],
        "sellingOpportunity": call_context['sellingOpportunity'],
        "final_sentiment": call_context['sentiment'],
        "customerIdentified": call_context['customerIdentified']
    }

    # Create a new item in the container
    cosmos_container.create_item(body=data)

    print("Call saved successfully to CosmosDB.")

def analyseCallFile(filename):
    """
    Performs continuous speech recognition with input from an audio file.
    
    Args:
        filename (str): The path of the audio file to be analyzed.
    
    Returns:
        None
    """
    speech_config = speechsdk.SpeechConfig(subscription=AZURE_AI_SPEECH_KEY, region=AZURE_AI_SPEECH_REGION)
    audio_config = speechsdk.audio.AudioConfig(filename=filename)

    auto_detect_source_language_config = speechsdk.languageconfig.AutoDetectSourceLanguageConfig(languages=["en-US"])
    speech_config.set_property(property_id=speechsdk.PropertyId.SpeechServiceConnection_LanguageIdMode, value='Continuous')
    speech_recognizer = speechsdk.SpeechRecognizer(speech_config=speech_config, 
                                                   audio_config=audio_config,
                                                   auto_detect_source_language_config=auto_detect_source_language_config
                                                   )

    done = False

    def stop_cb(evt):
        """
        Callback function to stop continuous speech recognition.

        Parameters:
        - evt: The event triggering the callback.

        Returns:
        None
        """
        print('CLOSING on {}'.format(evt))
        speech_recognizer.stop_continuous_recognition()
        nonlocal done
        done = True

    # Connect callbacks to the events fired by the speech recognizer
    if debug:
        # speech_recognizer.recognizing.connect(lambda evt: print('RECOGNIZING: {}'.format(evt))) # gets new texts as they come in
        speech_recognizer.recognized.connect(lambda evt: print('RECOGNIZED: {}'.format(evt))) # after a phrase being spoken, this event is fired
        speech_recognizer.session_started.connect(lambda evt: print('SESSION STARTED: {}'.format(evt))) # when transcription starts
        speech_recognizer.session_stopped.connect(lambda evt: print('SESSION STOPPED {}'.format(evt))) # when transcription ends
        speech_recognizer.canceled.connect(lambda evt: print('CANCELED {}'.format(evt))) # when transcription cancels due to errors

    # stop continuous recognition on either session stopped or canceled events
    speech_recognizer.session_stopped.connect(stop_cb)
    speech_recognizer.canceled.connect(stop_cb)

    # # Call analysis
    speech_recognizer.recognized.connect(register_transcript) # Saves the entire transcription
    speech_recognizer.recognizing.connect(handle_printable_text) # Saves the transcription to be displayed
    speech_recognizer.recognized.connect(call_analysis) # Analyzes the call

    # Start continuous speech recognition
    speech_recognizer.start_continuous_recognition()
    placeholder = st.empty()
    while not done:
        time.sleep(.5)
        with placeholder.container():
            col1, col2 = st.columns(2, gap="large")
            col1.text_area(label="Live Transcription", value=call_context['printable_text'], height=1000, key=random() )
            col2.metric(label="Sentiment", value=call_context['sentiment'])
            col2.metric(label="Selling Opportunity", value=call_context['sellingOpportunity'])
            if call_context['customerIdentified']:
                col2.metric(label="Customer identified?", value=call_context['customerIdentified']['identified'])
                col2.text_area(label="Customer Indentification", value=customer_identification(call_context['customerIdentified']), height=200, key=random())
            else:
                col2.metric(label="Customer identified?", value=None)
                col2.text_area(label="Customer Indentification", value=None, key=random())
            col2.text_area(label="Agent Next Best Action", value=call_context['nextBestAction'][-1], height=200, key=random())
            col2.expander(label="History of Next Best Actions",expanded=False).write(call_context['nextBestAction'][-1:0:-1])

#################################################################################
# END OF HELPER FUNCTIONS
#################################################################################

# Set environment
load_env = load_dotenv(find_dotenv('config.env'))
call_context = {}
debug = True

##### Check if the environment variables are loaded successfully
assert load_env, "Error loading environment variables. Make sure that you have the 'config.env' file in the root directory."

AZURE_AI_SPEECH_KEY = os.environ["SPEECH_KEY"]
AZURE_AI_SPEECH_REGION = os.environ["SPEECH_REGION"]
PROMPTFLOW_DEPLOYMENT_URL = os.environ["PROMPTFLOW_DEPLOYMENT_URL"]
PROMPTFLOW_DEPLOYMENT_KEY = os.environ["PROMPTFLOW_DEPLOYMENT_KEY"]
COSMOSDB_CONNECTION_URL = os.environ["COSMOSDB_CONNECTION_URL"]
COSMOSDB_CONNECTION_KEY = os.environ["COSMOSDB_CONNECTION_KEY"]
COSMOSDB_DATABASE_NAME = os.environ["COSMOSDB_DATABASE_NAME"]
COSMOSDB_CONTAINER_NAME = os.environ["COSMOSDB_CONTAINER_NAME"]

assert AZURE_AI_SPEECH_KEY, "No key has been configured for Azure AI Speech service."
assert AZURE_AI_SPEECH_REGION, "No region has been configured for Azure AI Speech service."
assert PROMPTFLOW_DEPLOYMENT_URL, "No URL has been configured for the Promptflow endpoint."
assert PROMPTFLOW_DEPLOYMENT_KEY, "No key has been configured for the Promptflow endpoint."
assert COSMOSDB_CONNECTION_URL, "Please specify the connection URL for CosmosDB."
assert COSMOSDB_CONNECTION_KEY, "Please specify the connection key for CosmosDB."
assert COSMOSDB_DATABASE_NAME, "Please specify the database name for CosmosDB."
assert COSMOSDB_CONTAINER_NAME, "Please specify the container name for CosmosDB."

st.set_page_config(
    page_title="Agent Assistance",
    page_icon="👋",
    layout="wide"
)

### Initialize CosmosDB client
# Create a Cosmos DB client
cosmos_client = CosmosClient(COSMOSDB_CONNECTION_URL, credential=COSMOSDB_CONNECTION_KEY)
# Get a reference to the database
cosmos_database = cosmos_client.get_database_client(COSMOSDB_DATABASE_NAME)

# Get a reference to the container
cosmos_container = cosmos_database.get_container_client(COSMOSDB_CONTAINER_NAME)

### Obtain list of calls
calls = os.listdir(os.path.join("Call Samples","Audio"))
calls = [ call.replace('.wav','') for call in calls ]
calls.sort()

### Start page definition
call_id =st.selectbox("Select a call", calls)
if st.button("Start"):
    init_session_state(call_id)
    analyseCallFile(call_context['audio_path'])
    print(call_context)
    saveCall()