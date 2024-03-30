---
layout: post
title: "Thoughts about ChatGpt"
subtitle: "Thoughts about ChatGpt"
category: writer
tags: doubts
---


{:toc}

# Introduction 
[Chat GPT](https://openai.com/blog/chatgpt) (Generative Pretrained Transformer) is one of the most advanced chatbot developed by OpenAI, which is featured to generate the human-like or human responses to text inputs.
Its version3.5 was launched on November 30, 2022, by San Francisco-based ([OpenAI](https://openai.com/blog/chatgpt)). Now version4 has been published. It provided the free chatbot service initially to collect the public feedback.Within five days of its launch, its user count had [broken 1 million](https://twitter.com/gdb/status/1599683104142430208)

![example](/assets/img/2020-08-02/about_chatgtp1.png)

# Training Process 
It is fine tuned based on **GPT-3.5** by using **Reinforcement Learning from Human Feedback (RLHF)**

- For supervised training, AI trainers would give the desired answer. It would provide a loss compared with answer from chatbot, which is used for supervised training

- For data collection, AI trainers give feedback on chats from chatbot and human, more specifically, they help both sides compose their responses. Then this new dialogue dataset is mixed with dataset from InstructGPT with dialogue format 

- For reinforcement learning, based on answers from chatbot under various conversions, human trainers would rank it by quality. Then fine-tune the model using [Proximal Policy Optimization](https://openai.com/blog/openai-baselines-ppo/)

![example](/assets/img/2020-08-02/about_chatgtp2.svg)

# Advantage 
1. After testing the free platform, I believe the response to be significantly more sophisticated and innovative than previous Silicon Valley chatbots - on par, even, **with a human search query that has collated all available answers to the same question**.
2. ChatGPT is stateful, being able to remember previous prompts given to it in the same conversation. 
![](/assets/img/2020-08-02/about_chatgtp3.png)

3. It can generate email, documents, or even code! 
![](/assets/img/2020-08-02/about_chatgtp4.png)

# Weakness 
1. ChatGPT's database only includes information prior to 2021, therefore it may not have the knowledge of events that occurred after that year.
2. While ChatGPT may come across as overconfident, it raises a valid question about the purpose of a chatbot. Do we require a chatbot with human-like qualities such as kindness, empathy, and emotional responses, even if it may make mistakes? Or is it sufficient to simply expect accurate information from the chatbot?


# Ideas 
1. **ChatGPT could have the potential to replace traditional search engines and browsers and mpact the way companies earn revenue through search-related advertisements**. It serves as a reminder that **innovation is still happening, and more fierce**. ChatGPT can provide a nearly instant, accurate, and comprehensive answer. Additionally, **it offers related links for further details**, something that is left to chance when using search engines.

2. **In the age of the internet, knowledge is no longer the competitive factor among us.** While search engines like ChatGPT have vast amounts of knowledge that surpass any human, **the most significant ability lies in human thinking**. With the ability to search for relevant information and build problem-solving pipelines, **humans can innovate and push boundaries beyond simply possessing knowledge**.

3. For ChatGPT to evolve further, **the incorporation of images and support for multiple languages should be prioritized.** While the addition of image support will require a substantial increase in database or RAM size, **incorporating more efficient training devices** like tensorrt could help achieve this.


# Refer
1. [Official Introduction](https://openai.com/blog/chatgpt/)
2. [Talk with ChatGPT](https://chat.openai.com/chat)
3. [Wiki ChatGPT](https://en.wikipedia.org/wiki/ChatGPT)

