# org-assistant.el
[![License](https://img.shields.io/badge/license-GPL_3-green.svg)](https://www.gnu.org/licenses/gpl-3.0.txt)
[![MELPA](https://melpa.org/packages/org-assistant-badge.svg)](https://melpa.org/#/org-runbook)
[![Version](https://img.shields.io/github/v/tag/tyler-dodge/org-assistant)](https://github.com/tyler-dodge/org-assistant/releases)

---

 Org babel extension for Chat Assistant APIs

## Usage

org-assistant provides support for accessing chat APIs such as ChatGPT in the context of an org
notebook.
It provides a function named org-assistant that serves as entrypoint for displaying an org assistant buffer.
Also, it can be used in any org file by using a src block like #+BEGIN_SRC assistant or #+BEGIN_SRC ?.

org-assistant uses the org tree in order to generate the message list whenever sending information to the chat endpoint.
It will only use messages from the branch of the tree that the block that initiated the request is in.  It does not include
example blocks or source blocks that appear later in the org buffer than the initiating block.
Example blocks are treated as being responses from the assistant by default if they occur after user messages.
If the example block is before any user source block, they are treated as system messages to the assistant instead.

### Example
```
* User Question
#+BEGIN_SRC ?
Hi
#+END_SRC

AI Response
#+BEGIN_EXAMPLE
Hello! How can I assist you today?
#+END_EXAMPLE
```



## Commands

* [org-assistant](#org-assistant) <a name="org-assistant"></a> 
Prompt the user for an initial prompt for the assistant
and display a window with the buffer containing the response.

* [org-babel-execute:assistant](#org-babel-execute%3Aassistant) <a name="org-babel-execute:assistant"></a> 
Executes an org-assistant.

This is intended to be called via org babel in a src block with Ctrl-C
Ctrl-C like:

```
#+BEGIN_SRC assistant
Hi
#+END_SRC
```

The response from the assistant will be in the example block
following:

```
#+BEGIN_EXAMPLE
Response
#+END_EXAMPLE
```

All of the messages that are in the same branch of the org tree are
included in the request to the assistant.
```
* Question
#+BEGIN_SRC assistant
Hi
#+END_SRC

#+BEGIN_EXAMPLE
Response
#+END_EXAMPLE

#+BEGIN_SRC assistant
What’s up?
#+END_SRC
```

Running babel on the second assistant block will send the
conversation:

```
User: Hi
Assistant: Response
User: What’s up?
```

Running babel on the first assistant block will only include the
messages before it:

```
User: Hi
```

Only messages in the same branch will be included:

```
* Question
#+BEGIN_SRC assistant
Hi
#+END_SRC

#+BEGIN_EXAMPLE
Response
#+END_EXAMPLE
** Branch A 
#+BEGIN_SRC assistant
Branch A
#+END_SRC

#+BEGIN_EXAMPLE
Branch A Response
#+END_EXAMPLE

** Branch B 
#+BEGIN_SRC assistant
Branch B
#+END_SRC

#+BEGIN_EXAMPLE
Branch B Response
#+END_EXAMPLE
```
If you ran Ctrl-C Ctrl-C on Branch B’s src block the conversation sent
to the endpoint would be:

```
User: Hi
Assistant: Response
User: Branch B
Assistant: Branch B Response
```



## Customization

* [org-assistant-auth-function](#org-assistant-auth-function)<a name="org-assistant-auth-function"></a> org-assistant-auth-function
Function used to get the secret key.
Optionally can be set directly to a string, in which case it will be
used as the OpenAI key.

* [org-assistant-buffer-name](#org-assistant-buffer-name)<a name="org-assistant-buffer-name"></a> org-assistant-buffer-name
The buffer name used for the org-assistant buffer.

* [org-assistant-model](#org-assistant-model)<a name="org-assistant-model"></a> org-assistant-model
The model used for the assistant.

* [org-assistant-endpoint](#org-assistant-endpoint)<a name="org-assistant-endpoint"></a> org-assistant-endpoint
The endpoint used for the assistant


## Contributing

Contributions welcome, but forking preferred. 
I plan to actively maintain this, but I will be prioritizing features that impact me first.

I'll look at most pull requests eventually, but there is no SLA on those being accepted. 
    
Also, I will only respond to pull requests on a case by case basis. 
I have no obligation to comment on, justify not accepting, or accept any given pull request. 
Feel free to start a fork that has more support in that area.

If there's a great pull request that I'm slow on accepting, feel free to fork and rename the project.
