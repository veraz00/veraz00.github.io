---
layout: post
title: "Tiktok Interview Journey"
subtitle: "Interview for Backend Engineer in Tiktok"
category: engineer 
tags: interview
---

<!--more-->

* this unordered seed list will be replaced by the toc
{:toc}


# Overview 
There are 3 tech interviews in total after getting the HR call. I failed in the 2nd one and experienced 2 interviews in total 


# Interview Time Schedule 
Scheduling interviews can be a tricky dance. Here's what I learned:

- **HR Hustle**: The HR team was great about scheduling interviews quickly, but the interviewers themselves sometimes needed to adjust the timing.
- **Early Bird Gets the Interview**: If possible, try to snag the earliest available interview slot. This can minimize the chances of delays later.
- **Avoid Calling HR**: My HR mentioned, She has the scheduled calls all the day. So avoid calling her but messages for requests like, interview feedbacks or reschedule.


# The 1st round of Tech Interview 

The first round was a video call. Though the position focused on backend inference (TRT) in Singapore, the interviewer, based in Vancouver, belonged to the training team.

**We kicked things off with my project, which utilized a bi-directional transformer**. He fired away some technical questions:

1. Why is there a self-attention before cross attention?
2. Why residual layer is better than classical cnn? 
> My answer is they have skip connection so it can transfer more features in front propoation. In the back propoagation, it can reduce the gradient vanish problem, which brings me into the next question.
3. Why skip connection can avoid vanish gradient problem? 


**The conversation then transitioned to the core focus of the position - inference and TensorRT**
1. Beside those quantilization methods, any other way u can improve the inference speed? 
2. How is the memory and speed change after pruning/ quantilization methods? 


Finally, there is **a real-time coding**. *As long as I moved ur mouse out of the IDE, it can be found. Based on that, search problems or cheating is quite hard, even though sharing screen is not required*. The coding part includes: 

1. Self-attention layer 
2. Multi-head self-attention layer 

**During the coding time, the interviewer reminded me of some layers that I missed**. After the coding session, the interviewer continued with questions related to the implemented layers: 

1. What's the advantage of multi-head attention compared to non multi-head one? 
2. Where should we put the mask? what is the mask used for? 

While I didn't nail every question, particularly during the real-time coding and post-coding discussions, the interviewer's reminders were helpful. **The key takeaway?** It's okay to admit you don't know something and try to figure out the answers. *I guess, honesty and a willingness to learn go a long way in these situations?*


# The 2nd round of Tech Interview 

After the 1st round, I messaged the hr immediately so the 2nd round was arranged the next day. 

The second round brought me a video call with the Singapore-based inference team, the team I ultimately wanted to join. **We jumped right into one of my projects on object classification, where I utilized YOLOv8**.
1. What is the structure features of yolov8? 
2. Have u used maskrnn? Give a comparision between yolov8 and maskrnn?
> I have to admit, I did not know maskrcnn 
3. Give a comparion between swin transformer and VIT. 
> Shit, at that time, I totally forgot that VIT! So I say, I am not familir with VIT. hhh, only god can save me!

**The next part of the interview focused on my expertise in TensorRT (TRT) for inference:**
1. The difference between script and tracing? 
> Come on, nowadays we often just compile or onnx? I totally did not work on torchscript 
2. Do you know how to debug layer by layer in tensorrt? 
3. Seeing you mentioned the improvement on speed in this project, what did you do? 

**Finally he gave me a leetcode test.** The same IDE as I used in the 1st time. **The question is from [Leetcode: Basic Calculator](https://leetcode.com/problems/basic-calculator/description/)**. While I acknowledged it quite challenging (As many ppl shared, algorithm test from Tiktok is on hard level), I wasn't able to solve it. 