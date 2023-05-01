# org-assistant.el
[![License](https://img.shields.io/badge/license-GPL_3-green.svg)](https://www.gnu.org/licenses/gpl-3.0.txt)
[![MELPA](https://melpa.org/packages/org-assistant-badge.svg)](https://melpa.org/#/org-assistant)
[![Version](https://img.shields.io/github/v/tag/tyler-dodge/org-assistant)](https://github.com/tyler-dodge/org-assistant/releases)


---

 Org babel extension for Chat Assistant APIs

## Usage

org-assistant provides support for accessing chat APIs such as
ChatGPT in the context of an org notebook.

It provides a function named org-assistant that serves as
entrypoint for displaying an org assistant buffer.  Also, it can be
used in any org file by using a src block like #+BEGIN_SRC
assistant or #+BEGIN_SRC ?.

The API Key is looked up via org-assistant-auth-function, which has
meen tested using the MacOS Keychain.  Alternatively,
org-assistant-auth-function can be a string and directly set to
your API key.

org-assistant uses the org tree in order to generate the message
list whenever sending information to the chat endpoint.  It will
only use messages from the branch of the tree that the block that
initiated the request is in.  It does not include example blocks or
source blocks that appear later in the org buffer than the
initiating block.  Example blocks are treated as being responses
from the assistant by default if they occur after user messages.
If the example block is before any user source block, they are
treated as system messages to the assistant instead.

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

## Comparison With Other AI Packages
### [org-assistant.el](https://github.com/tyler-dodge/org-assistant) and [org-ai.el](https://github.com/rksm/org-ai)
- [org-ai.el](https://github.com/rksm/org-ai) is focused more on runtime interaction with AI
- [org-assistant.el](https://github.com/tyler-dodge/org-assistant) is focused more on reproducible sessions
    via org babel
- [org-assistant.el](https://github.com/tyler-dodge/org-assistant) supports branching conversations
- [org-assistant.el](https://github.com/tyler-dodge/org-assistant) is not meant to be used downstream
     as a library for AI endpoint interactions.
- In [org-assistant.el](https://github.com/tyler-dodge/org-assistant), all interaction is async using org-babel, which allows
    for notebook style prompt development
- In [org-ai.el](https://github.com/rksm/org-ai), interaction is synchronous and inline,
    which is better for in-editor use cases
- [org-ai.el](https://github.com/rksm/org-ai) supports a lot of other AI use cases like text to speech

### [org-assistant.el](https://github.com/tyler-dodge/org-assistant) and [gptel](https://github.com/karthink/gptel)
- Most of the same differences and similarities apply from
    [org-assistant.el](https://github.com/tyler-dodge/org-assistant) and [org-ai.el](https://github.com/rksm/org-ai)

### Feel free to add a pull request detailing the differences if there is a package I missed





## Commands

* [org-assistant](#org-assistant) <a name="org-assistant"></a>:
Prompt the user for an initial prompt for the assistant.

Then display a window with the buffer containing the response.

* [org-babel-execute:assistant](#org-babel-execute%3Aassistant) <a name="org-babel-execute:assistant"></a>:
Execute an ‘org-assistant’ in an org-babel context.

PARAMS is used to enable noweb mode.
If :list-models is set, the ‘org-assistant-models-endpoint’
will be called instead.

TEXT must be empty if :list-models is set.

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

‘org-assistant’ also supporst image generation.
If the :file attribute is set, the image API will be used.

The following is an example of using the image endpoint:

```
#+BEGIN_SRC assistant :file output.png
An image of the GNU mascot
#+END_SRC
```

* [org-babel-execute:?](#org-babel-execute%3A?) <a name="org-babel-execute:?"></a>:
See ‘org-babel-execute:assistant’.

ARGS is routed as is.

* [org-assistant-explain-function](#org-assistant-explain-function) <a name="org-assistant-explain-function"></a>:
Ask the assistant to explain the function at point.

* [org-assistant-write-docstring](#org-assistant-write-docstring) <a name="org-assistant-write-docstring"></a>:
Ask the assistant to generate a docstring for the function at point.


## Customization

* [org-assistant-auth-function](#org-assistant-auth-function)<a name="org-assistant-auth-function"></a>:
Function used to get the secret key.
Optionally can be set directly to a string, in which case it will be
used as the OpenAI key.

* [org-assistant-mode-visual-line-enabled](#org-assistant-mode-visual-line-enabled)<a name="org-assistant-mode-visual-line-enabled"></a>:
When non-nil, `visual-line-mode' is enabled with `org-assistant-mode'.

* [org-assistant-buffer-name](#org-assistant-buffer-name)<a name="org-assistant-buffer-name"></a>:
The buffer name used for the `org-assistant' buffer.

* [org-assistant-mode-line-format](#org-assistant-mode-line-format)<a name="org-assistant-mode-line-format"></a>:
The `mode-line-format' used by the `org-assistant' buffer.

Set to nil to use `mode-line-format' instead.

* [org-assistant-model](#org-assistant-model)<a name="org-assistant-model"></a>:
The model used for the assistant.

* [org-assistant-curl-command](#org-assistant-curl-command)<a name="org-assistant-curl-command"></a>:
The path to the curl command used to run requests.

* [org-assistant-endpoint](#org-assistant-endpoint)<a name="org-assistant-endpoint"></a>:
The endpoint used for the assistant.
`org-assistant-endpoint-path-chat' and `org-assistant-endpoint-path-image'
contain the paths for the respective APIs.

* [org-assistant-endpoint-path-chat](#org-assistant-endpoint-path-chat)<a name="org-assistant-endpoint-path-chat"></a>:
The path used for the chat API.
See `org-assistant-endpoint' for the domain.

* [org-assistant-endpoint-path-models](#org-assistant-endpoint-path-models)<a name="org-assistant-endpoint-path-models"></a>:
The path used for the list models API.
See `org-assistant-endpoint' for the domain.

* [org-assistant-endpoint-path-image](#org-assistant-endpoint-path-image)<a name="org-assistant-endpoint-path-image"></a>:
The endpoint used for the assistant.

* [org-assistant-parallelism](#org-assistant-parallelism)<a name="org-assistant-parallelism"></a>:
The max inflight requests to send with `org-assistant' at once.


## Contributing

Contributions welcome, but forking preferred. 
I plan to actively maintain this, but I will be prioritizing features that impact me first.

I'll look at most pull requests eventually, but there is no SLA on those being accepted. 
    
Also, I will only respond to pull requests on a case by case basis. 
I have no obligation to comment on, justify not accepting, or accept any given pull request. 
Feel free to start a fork that has more support in that area.

If there's a great pull request that I'm slow on accepting, feel free to fork and rename the project.
