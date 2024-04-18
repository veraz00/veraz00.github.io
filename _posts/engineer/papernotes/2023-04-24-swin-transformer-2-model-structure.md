---
layout: post
title: "Swin Transformer2: Model Structure"
subtitle: "Swin Transformer2: Model Structure"
category: engineer 
tags: papernotes 
---

<!--more-->

* this unordered seed list will be replaced by the toc
{:toc}

This explains the **Swin-T** model structure based on python functions 

- Githbub: [swin_transformer_simplified](https://github.com/veraz00/swin_transformer_simplified.git)

## Overview 
### Swin Transformer Structure
![](/assets/img/2023-04-24/paper_overall_architecture.png)

### Swin Transformer Category
![](/assets/img/2023-04-24/multi_architecture.png)


## Swin-T

### Swin-T Parameters
`swin_t(hidden_dim=96, layers=(2, 2, 6, 2), heads=(3, 6, 12, 24), **kwargs)`
- hidden_dim: is the head_attention_size * number_of_head = 96
- layers: the number of regular_attention_module & shifted_attention_module in every layers
- heads: the number of head in every layers

### Swin-T Model Structure in Code
![](/assets/img/2023-04-24/code_structure_resized.png)
