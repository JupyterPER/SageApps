priming_ai_assistant = {
'Complete':'''
**Your name is AI and you are a coding assistant. You are helping the user complete the SageMath code they are trying to write.**

Here are the requirements for completing the SageMath code:

- Only complete the SageMath code according to INSTRUCTIONS below.
- Do not repeat any code from the PREVIOUS CODE below.
- Do not import any library.
- Do not import any commands from libraries.
- Do not provide a code as a function, only if the user explicitly asks you to.
- Only put the completed code in a function, if the user explicitly asks you to.
- Provide code that is intelligent, correct, efficient, and readable.
- Do not give any summarizing comments before or after the SageMath code.
- If you are not sure about something, don't guess. 
- Keep your responses short and to the point.
- Never refer to yourself as "AI", you are a coding assistant.
- Never ask the user for a follow-up. Do not include pleasantries at the end of your response.
- Briefly summarise the new code you wrote and this summarization put
as a Python comment at the beginning of your code 
- Give only your code and Python comments, no other texts or notes, do not use Markdown for your output
- Curly braces in this prompt are represented by ASCII codes &#123, &#125
- Use standard symbols for curly braces instead ASCII codes &#123, &#125 in your response
''', 

'Format':'''
**Your name is AI and you are a coding assistant. You are helping the user to improve the SageMath code formatting in the LAST CELL.**

Here are the requirements for improving the formatting of the SageMath code:

- Never alter the SageMath code itself, only improve the formatting.
- Do not include import statements in your response, only the SageMath code itself.
- Improvements that you need to make where possible:
    - Do not add extra commands to existing commands
    - Add comments to explain what the SageMath code is doing.
    - Improve the spacing of the SageMath code to make it easier to read.
    - Add docstrings to functions and classes.
    - Add summarizing comments for algorithmic structures.
    - In docstrings explain the parameters of existing functions and classes.
    - Check existing docstrings and modify them if they are not relevant.
    - Check existing comments and modify them if they are not relevant.
- Only put the formatting code in a function if the original code was in a function, otherwise just improve the formatting of the SageMath code.
- If you are not sure about something, don't guess. 
- Keep your responses short and to the point.
- Never refer to yourself as "AI", you are a coding assistant.
- Never ask the user for a follow-up. Do not include pleasantries at the end of your response.
- Curly braces in this prompt are represented by ASCII codes &#123, &#125
- Use standard symbols for curly braces instead of ASCII codes &#123, &#125 in your response.
''',

'Explain': '''

**Your name is AI and you are a coding assistant. You are helping the user understand the SageMath code in the FOCAL CELL by explaining it.**

Here are the requirements for your explanation:

- Explain the SageMath code in the FOCAL CELL as clearly as possible.
- If you are not sure about something, don't guess. 
- Keep your responses short and to the point.
- Never refer to yourself as "AI", you are a coding assistant.
- Never ask the user for a follow-up. Do not include pleasantries at the end of your response.
- Use markdown to format your response where possible.
- If reasonable, provide a line-by-line explanation of the SageMath code using markdown formatting and clearly labelled inline comments. 
- Curly braces in this prompt are represented by ASCII codes &#123, &#125
- Use standard symbols for curly braces instead of ASCII codes &#123, &#125 in your response
'''
}

# Load Mistral
from mistralai import Mistral
import re
import time

from IPython.display import IFrame, display, HTML, Markdown, display_html
md = lambda text: display(Markdown(text))

# Define the dictionary for model names
model_dict = {
    "small": "mistral-small-latest",
    "medium": "mistral-medium-latest",
    "large": "mistral-large-latest"
}


def replace_curly_braces(input_string):
    output_string = input_string.replace('{', '&#123;').replace('}', '&#125;')
    return output_string

def sanitize_long_data_raw_by_lines(text, line_threshold=20, head_lines=10, tail_lines=5):
    """
    Shortens triple-quoted strings that start with 'data_raw =' based on line count.

    Args:
        text (str): Input text to sanitize
        line_threshold (int): Number of lines above which string is considered too long
        head_lines (int): Number of lines to keep at the start
        tail_lines (int): Number of lines to keep at the end

    Returns:
        str: Text with long 'data_raw =' strings shortened
    """
    pattern = r'^(data_raw\s*=\s*r""")(.*?)("""\s*)$'
    
    def replacer(match):
        prefix = match.group(1)
        content = match.group(2)
        suffix = match.group(3)
        lines = content.splitlines()
        if len(lines) > line_threshold:
            new_content = "\n".join(
                lines[:head_lines] + ["\n.\n.\n.\n"] + lines[-tail_lines:]
            )
            return prefix + new_content + suffix
        else:
            return match.group(0)
    
    sanitized = re.sub(pattern, replacer, text, flags=re.DOTALL|re.MULTILINE)
    return sanitized
    

def sanitize_Ins(text):
    """
    Replaces content between "# -START OF AI CELL-" and "# -END OF AI CELL-" markers with "#".

    Args:
        text (str): Input string with AI cell code
    Returns:
        str: Text with AI cell replaced by "#"
    """
    pattern = r'# -START OF AI CELL-.*?# -END OF AI CELL-'
    text = sanitize_long_data_raw_by_lines(text)
    sanitized_ai = re.sub(pattern, '#', text, flags=re.DOTALL)
    return sanitized_ai

def AI_generate(message, model = None, api_key = ''):
    """
    Analyzes the given message using the specified model.

    Args:
        message (str): The message to analyze.
        model (str): The model to use for analysis (default is 'mistral-small-latest').

    Returns:
        str: The result of the analysis.
    """
    # setting AI model
    if model is None: 
        model = os.getenv('LLM')
    #print(f'model={model}, language={Lang}')
    
    s = Mistral(api_key=api_key)  # Initialize the Mistral API client
    res = s.chat.complete(model=model, messages=[{"content": message, "role": "user"}])  # Get response from model

    if res is not None:
        return res.choices[0].message.content  # Extract and return the answer from the response
    return "Error: No response received."
    

def add_language(message, language):
    if language.lower() not in ['eng', 'english']:
        message += '- Provide your answer (all your comments and helps) in the following desired language (make a translation into it): **' + language + '**' +'''
        - DO NOT modify the commands in the SageMath code regarding the desired language.
        - PROVIDE comments in the SageMath code in the desired language''' 
    return message


def all_outputs(outputs):
    return '\n'.join([f'Out[{i}]: \n {item}' for i, item in enumerate(outputs)])

def prev_code(inputs):
    '''
    This function formats the previous code from the In list.
    '''
    return '\n'.join([f'In[{i+1}]:\n{item}\n' for i, item in enumerate(inputs[1:])])
    
def extract_last_in(text):
    lines = text.split('\n')
    for i in range(len(lines)-1, -1, -1):
        if lines[i].startswith('In['):
            return '\n'.join(lines[i:]).split(':', 1)[1]
    return ''

def AI_ask(replace=True, language=None,model=None,print_prompt=False):
  
    # setting AI parameters
    # Call the helper function to check AI parameters
    model, language = check_AI_parameters(model, language)
    
    # If model or language are None, nothing is done (indicating an error)
    if model is None or language is None:
        return
   
    # prompt for Complete
    inputs = get_ipython().user_ns['In']
    message = add_language(priming_ai_assistant['Question'], language)
    instructions ='''
    **Here is the task, question or query that the user is asking you:**
    *TASK:*
    ''' + '\n'+ inputs[-2]
    prompt = message + instructions 
    
    if print_prompt: print(prompt)
    
    # AI processing
    AIresult = "md('''\n\n{}\n\n''')".format(AI_generate(prompt, model=model))
    get_ipython().set_next_input(AIresult, replace=replace)
    return #print(AIresult)

def AI_complete(replace=True, language=None, output=False, model=None, print_prompt=False, NBplayer_code=None, api_key = ''):
    NBplayer_code = sanitize_Ins(NBplayer_code)
    if NBplayer_code==None:
        # setting AI parameters
        # Call the helper function to check AI parameters
        model, language = check_AI_parameters(model, language)
        
        # If model or language are None, nothing is done (indicating an error)
        if model is None or language is None:
            return
        
        # prompt for Complete
        inputs = get_ipython().user_ns['In']
        #print(inputs[0:-2])
        message = add_language(priming_ai_assistant['Complete'], language)
            
            
        previous_code ='''
        **Here is the background information about the SageMath code:**
        *PREVIOUS CODE:*
        '''+prev_code(inputs[0:-2])+'\n'
        instructions  = '''
        **Here are INSTRUCTIONS for completing code:**
        ''' + '\n'+ inputs[-2]
        if output:
            outputs = get_ipython().user_ns['Out']
            output_str = '''
            *OUTPUT:*
            '''+'\n'+ all_outputs(outputs)
            prompt = message + previous_code +  output_str + instructions
        else:
            prompt = message + previous_code + instructions 
        
        if print_prompt: print(prompt)
        
        # AI processing
        AIresult = AI_generate(prompt, model=model, api_key=api_key)
        AIresult = AIresult.replace('```python','')
        AIresult = AIresult.replace('```','')
        get_ipython().set_next_input(AIresult, replace=replace)
        return #print(AIresult)
    else:
        previous_code = 'In['.join(NBplayer_code.split('In[')[:-2])
        instructions = extract_last_in(NBplayer_code)
        message = add_language(priming_ai_assistant['Complete'], language)
        prompt = message + previous_code + instructions
        # AI processing
        AIresult = AI_generate(prompt, model=model, api_key=api_key)
        AIresult = AIresult.replace('```python','')
        AIresult = AIresult.replace('```','')
        return AIresult
    
def AI_format(n=-2, replace=True, language=None, model=None, print_prompt=False, NBplayer_code=None, api_key=''):
    NBplayer_code = sanitize_Ins(NBplayer_code)
    if NBplayer_code==None:
        # setting AI parameters
        # Call the helper function to check AI parameters
        model, language = check_AI_parameters(model, language)
        
        # If model or language are None, nothing is done (indicating an error)
        if model is None or language is None:
            return
        
        # prompt for Format
        inputs = get_ipython().user_ns['In']
        message = add_language(priming_ai_assistant['Format'], language)
        last_code ='''
        **Here is the SageMath code of the LAST CELL:**
        '''+'\n'+ inputs[n]
        prompt = message + last_code
        
        if print_prompt: print(prompt)
        
        # AI processing
        AIresult = AI_generate(prompt, model=model, api_key=api_key)
        AIresult = AIresult.replace('```python','')
        AIresult = AIresult.replace('```','')
        get_ipython().set_next_input(AIresult, replace=replace)
        return #print(AIresult)
    else:
        message = add_language(priming_ai_assistant['Format'], language)
        last_code = extract_last_in(NBplayer_code)
        prompt = message + last_code
        # AI processing
        AIresult = AI_generate(prompt, model=model, api_key=api_key)
        AIresult = AIresult.replace('```python','')
        AIresult = AIresult.replace('```','')
        return AIresult

    
def AI_explain(replace=True, addition='', language=None, previous_code=True, model=None, print_prompt=False, NBplayer_code=None, api_key=''):
    NBplayer_code = sanitize_Ins(NBplayer_code)
    if NBplayer_code==None:
        # Call the helper function to check AI parameters
        model, language = check_AI_parameters(model, language)
        
        # If model or language are None, nothing is done (indicating an error)
        if model is None or language is None:
            return
        
        # prompt for Format
        inputs = get_ipython().user_ns['In']
        outputs = get_ipython().user_ns['Out']
        message = add_language(priming_ai_assistant['Explain'], language)
        focal_code ='''
        *FOCAL CELL:*
        '''+'\n'+ inputs[-2]
           
        if previous_code:
            prev_code_str ='''
            *PREVIOUS CODE:*
            '''+'\n'+ prev_code(inputs[0:-2])
            outputs_str = '''
            *OUTPUTS:*
            '''+'\n'+ all_outputs(outputs)
            prompt = message + prev_code_str + focal_code + outputs_str
        else:
            prompt = message + focal_code
            
        if addition != '':
            add_prompt ='''
            *ADDITIONAL REQUEST:*
            '''+'\n'+ addition
            prompt += addition
            
        if print_prompt: print(prompt)
        
        # AI processing
        AIresult = "md('''\n\n{}\n\n''')".format(AI_generate(prompt, model=model, api_key=api_key))
        get_ipython().set_next_input(AIresult, replace=replace)
        return #print(AIresult)
    
    else:
        message = add_language(priming_ai_assistant['Explain'], language)
        if previous_code:
            prev_code_str = 'In['.join(NBplayer_code.split('In[')[:-2])
            focal_code = extract_last_in(NBplayer_code)
            prompt = message + prev_code_str + focal_code
        else:
            focal_code = extract_last_in(NBplayer_code)
            prompt = message + focal_code
            
        if addition != '':
            add_prompt ='''
            *ADDITIONAL REQUEST:*
            '''+'\n'+ addition
            prompt += addition
            
        # AI processing
        AIresult = AI_generate(prompt, model=model, api_key=api_key)
        return "\n{}\n".format(AIresult)
