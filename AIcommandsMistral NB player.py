priming_ai_assistant = {
'Complete':'''
**Your name is AI and you are a coding assistant. You are helping the user complete the code they are trying to write.**

Here are the requirements for completing the code:

- Only complete the code according to INSTRUCTIONS below, which start with #.
- Do not repeat any code from the PREVIOUS CODE below.
- Do not import any library.
- Do not import any commands from libraries.
- Do not provide a code as a function, only if the user explicitly asks you to.
- Only put the completed code in a function, if the user explicitly asks you to.
- Provide code that is intelligent, correct, efficient, and readable.
- Do not give any summarizing comments before or after the code.
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
**Your name is AI and you are a coding assistant. You are helping the user to improve the code formatting in the LAST CELL.**

Here are the requirements for improving the formatting of the code:

- Never alter the code itself, only improve the formatting.
- Do not include import statements in your response, only the code itself.
- Improvements that you need to make where possible:
    - Do not add extra commands to existing commands
    - Add comments to explain what the code is doing.
    - Improve the spacing of the code to make it easier to read.
    - Add docstrings to functions and classes.
    - Add summarizing comments for algorithmic structures.
    - In docstrings explain the parameters of existing functions and classes.
    - Check existing docstrings and modify them if they are not relevant.
    - Check existing comments and modify them if they are not relevant.
- Only put the formatting code in a function if the original code was in a function, otherwise just improve the formatting of the code.
- If you are not sure about something, don't guess. 
- Keep your responses short and to the point.
- Never refer to yourself as "AI", you are a coding assistant.
- Never ask the user for a follow-up. Do not include pleasantries at the end of your response.
- Curly braces in this prompt are represented by ASCII codes &#123, &#125
- Use standard symbols for curly braces instead of ASCII codes &#123, &#125 in your response.
''',

'Debug': '''
**Your name is AI and you are a coding assistant. You are helping the user to debug a code issue in their FOCAL CELL.**

Here are the requirements for debugging:

- Describe the problem in the FOCAL CELL as clearly as possible.
- Explain why the code is not working and/or throwing an error.
- Explain how to fix the problem.
- If you are not sure about something, don't guess. 
- Keep your responses short and to the point.
- Provide your explanation and solution formatted as markdown where possible.
- Never refer to yourself as "AI", you are a coding assistant.
- Never ask the user for a follow-up. Do not include pleasantries at the end of your response.
- Curly braces in this prompt are represented by ASCII codes &#123, &#125
- Use standard symbols for curly braces instead of ASCII codes &#123, &#125 in your response
''',

'Explain': '''

**Your name is AI and you are a coding assistant. You are helping the user understand the code in the FOCAL CELL by explaining it.**

Here are the requirements for your explanation:

- Explain the code in the FOCAL CELL as clearly as possible.
- If you are not sure about something, don't guess. 
- Keep your responses short and to the point.
- Never refer to yourself as "AI", you are a coding assistant.
- Never ask the user for a follow-up. Do not include pleasantries at the end of your response.
- Use markdown to format your response where possible.
- If reasonable, provide a line-by-line explanation of the code using markdown formatting and clearly labelled inline comments. 
- Curly braces in this prompt are represented by ASCII codes &#123, &#125
- Use standard symbols for curly braces instead of ASCII codes &#123, &#125 in your response
''',
'Review': '''
**Your name is AI and you are a code reviewer reviewing the code in the FOCAL CELL.**

Here are the requirements for reviewing code:

- Be constructive and suggest improvements where helpful.
- Do not include compliments or summaries of the code. 
- Do not comment on code that is not in the focal cell.
- You don't know the code that comes after the cell, so don't recommend anything regarding unused variables.
- Ignore suggestions related to imports. 
- Try to keep your comments short and to the point.
- When providing a suggestion in your list, reference the line(s) of code that you are referring to in a markdown code block right under each comment.
- Do not end your response with the updated code.
- If you are not sure about something, don't comment on it.
- Provide your suggestions formatted as markdown where possible.
- Never refer to yourself as "AI", you are a coding assistant.
- Never ask the user for a follow-up. Do not include pleasantries at the end of your response.
- Curly braces in this prompt are represented by ASCII codes &#123, &#125
- Use standard symbols for curly braces instead of ASCII codes &#123, &#125 in your response
''',

'Improve':
'''
**You are a coding assistant specializing in code optimization. Your task is to analyze the code provided in the FOCAL CELL and respond with improved, more efficient code only.**

Here are the requirements for improving code:

- Provide only the optimized, adjusted code as your response.
- Do not include explanations, comments, or suggestions outside of the code itself.
- Focus on improving efficiency, readability, and adherence to best practices.
- Ensure the optimized code maintains the original functionality.
- If multiple optimizations are possible, implement all of them in your response.
- Do not comment on or modify code outside the focal cell.
- Ignore issues related to imports or unused variables that may be used in subsequent code.
- Provide the entire optimized code block, even if only a small part has changed.
- If no meaningful optimizations can be made, respond with the original code unchanged.
- Never refer to yourself in any way or include any text outside of the code block.
- Do not ask for clarifications or follow-ups.
- Curly braces in this prompt are represented by ASCII codes &#123, &#125
- Use standard symbols for curly braces instead of ASCII codes &#123, &#125 in your response
''',

'Question': '''
**You are an excelent teacher of STEM. Your task is to help to answer, explain and understand
a posed question or query from math, science, technology or engineering.

YOUR COMMENTS requirements
- Be respectful, and constructive.
- Recognize and state the domain of the problem, so if it is from math, science, etc.
- Clearly explain and comment on your ideas and logic of steps.
- Try to keep your comments short and to the point.
- Do not include pleasantries at the end of your response.
- Use both qualitative and quantitative descriptions.
- Do not ask for clarifications or follow-ups.
- If you are not sure about something, don't guess. 
- Only provide code if the user explicitly asks you to.
- When providing code, make sure it is intelligent, correct, efficient, and readable.
- Prefer SageMath code over Sympy or over Python if the task is from math or science.
- Prefer Scientific Python and Data Science if the task deals with data.
- Curly braces in this prompt are represented by ASCII codes &#123, &#125
- Use standard symbols for curly braces instead of ASCII codes &#123, &#125 in your response

FORMATTING requirements
- Use Markdown to format your text.
- Use LATEX to format your equations.
- Do not put inline inline equations or math expressions into \\(.. \\) 
- Put inline equations between two dollars $.. $ , if the equation is in line.
- Do not use environment \\[ .. \\] for block centered equations or math expressions.
- Put LATEX equations between two doubledollars $$.. $$ , if the equation is alone, in the center of your text.
- Format the providing code and completions as markdown code blocks.
- Create a structured answer or explanation using bullets if it is appropriate.
'''
}

# Load Mistral
from mistralai import Mistral
import os
import time

from IPython.display import IFrame, display, HTML, Markdown, display_html
md = lambda text: display(Markdown(text))

# Define the dictionary for model names
model_dict = {
    "small": "mistral-small-latest",
    "medium": "mistral-medium-latest",
    "large": "mistral-large-latest"
}

def AI_set(cell_number=-2):
    """
    Automatically retrieves variables from a given cell in a Jupyter notebook and sets them as environment variables.
    If the variable 'LLM' is present, it applies the model dictionary to set the full model name.

    Args:
        cell_number (int): The number of the cell to retrieve variables from (e.g., In[3] -> cell_number = 3).
    """
    # Retrieve the cell content using the In[] object
    inputs = get_ipython().user_ns['In']
    cell_content = inputs[cell_number]
    
    # Create a dictionary to store the variables
    env_vars = {}
    
    # Execute the cell content to capture the variables
    exec(cell_content, globals(), env_vars)
    
    # Set each variable as an environment variable
    for var_name, value in env_vars.items():
        if not var_name.startswith('__'):  # Avoid system-defined variables
            
            # Special handling for 'LLM' to map to full model name
            if var_name == 'LLM' and value in model_dict:
                value = model_dict[value]  # Map 'small', 'medium', 'large' to full model name

            # Set the variable as an environment variable
            os.environ[var_name] = str(value)  # Convert value to string if necessary
            print(f"Set AI parameter {var_name}=\'{value}\' in the environment.")



def check_AI_parameters(model=None, language=None):
    """
    Checks if the required AI parameters as environmental variables ('LLM' and 'Lang') exist,
    and sets the model and language if they are not provided as arguments.

    Args:
        model (str): The model to use for AI processing.
        language (str): The language to use for the prompt.

    Returns:
        tuple: A tuple (model, language) with the appropriate values or None if missing.
    """
    # Check if the environment variables exist, and model/language are provided
    if os.getenv('LLM') is None and model is None:
        print("Error: 'LLM' for AI is not set as an environment variable or no LLM model is provided.")
        return None, None  # Return None to indicate failure
    if os.getenv('Lang') is None and language is None:
        print("Error: 'Lang' for AI is not set as an environment variable or no language is provided.")
        return None, None  # Return None to indicate failure
    
    # Set model and language if not provided
    if model is None:
        model = os.getenv('LLM')
    if language is None:
        language = os.getenv('Lang')
    
    print(f'model=\'{model}\', language=\'{language}\'')
    
    return model, language


def replace_curly_braces(input_string):
    output_string = input_string.replace('{', '&#123;').replace('}', '&#125;')
    return output_string

def AI_generate(message, model = None, api_key = 'fF41hEUSg4qYVYP0QihdZwyVSIOjdIp0'):
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
        - DO NOT modify the commands in the code regarding the desired language.
        - PROVIDE comments in the code in the desired language''' 
    return message

def last_error():
    errors = get_ipython().user_ns['Err']
    last_err_idx = list(errors.keys())[-1]
    last_err = errors[last_err_idx].split('\n')[-1]
    return last_err

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
        **Here is the background information about the code:**
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
        **Here is the code of the LAST CELL:**
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

def AI_debug(replace=True, language=None, model=None, print_prompt=False):

    # setting AI parameters
    # Call the helper function to check AI parameters
    model, language = check_AI_parameters(model, language)
    
    # If model or language are None, nothing is done (indicating an error)
    if model is None or language is None:
        return

    
    # prompt for Format
    inputs = get_ipython().user_ns['In']
    message = add_language(priming_ai_assistant['Debug'], language)
    last_code ='''
    **Here is the background information about the code:**
    '''+'\n'+ inputs[-2]
    last_err = '''
    *Here is the last error:*
    ''' + '\n' + last_error()
    prompt = message + last_code + last_err
    
    if print_prompt: print(prompt)

    
    # AI processing
    AIresult = AI_generate(prompt, model=model)
    AIresult = "md('''\n\n{}\n\n''')".format(AIresult)
    get_ipython().set_next_input(AIresult, replace=replace)
    return #print(AIresult)

def AI_explain(replace=True, addition='', language=None, previous_code=True, model=None, print_prompt=False):

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
    AIresult = "md('''\n\n{}\n\n''')".format(AI_generate(prompt, model=model))
    get_ipython().set_next_input(AIresult, replace=replace)
    return #print(AIresult)
    
def AI_explain(replace=True, addition='', language=None, previous_code=True, model=None, print_prompt=False, NBplayer_code=None, api_key=''):
    
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
        return "md('''\n\n{}\n\n''')".format(AIresult)

def AI_review(replace=True, addition='', language=None, previous_code=False, model=None, print_prompt=False):

    # setting AI parameters
    # Call the helper function to check AI parameters
    model, language = check_AI_parameters(model, language)
    
    # If model or language are None, nothing is done (indicating an error)
    if model is None or language is None:
        return
        
    # prompt for Format
    inputs = get_ipython().user_ns['In']
    outputs = get_ipython().user_ns['Out']
    message = add_language(priming_ai_assistant['Review'], language)
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
    AIresult = "md('''\n\n{}\n\n''')".format(AI_generate(prompt, model=model))
    get_ipython().set_next_input(AIresult, replace=replace)
    return #print(AIresult)

def AI_improve(replace=True, addition='', language=None, previous_code=False, model=None, print_prompt=False):
    
    # setting AI parameters
    # Call the helper function to check AI parameters
    model, language = check_AI_parameters(model, language)
    
    # If model or language are None, nothing is done (indicating an error)
    if model is None or language is None:
        return
      
    # prompt for Format
    inputs = get_ipython().user_ns['In']
    outputs = get_ipython().user_ns['Out']
    message = add_language(priming_ai_assistant['Improve'], language)
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
    AIresult = AI_generate(prompt, model=model)
    AIresult = AIresult.replace('```python','')
    AIresult = AIresult.replace('```','')
    get_ipython().set_next_input(AIresult, replace=replace)
    return #print(AIresult)
