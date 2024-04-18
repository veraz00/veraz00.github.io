---
layout: post
title: "SAM1: Auto-Generate Mask"
subtitle: "SAM1: Auto-Generate Mask"
category: engineer 
tags: papernotes 
---

<!--more-->

* this unordered seed list will be replaced by the toc
{:toc}


## Objective 

I would like to give some high-level explanation for how **segment-anything model (SAM)** automatically generates masks for the whole image. 

- Link: https://ai.meta.com/research/publications/segment-anything/
- Github: https://github.com/facebookresearch/segment-anything


The corresponding code is available on [GitHub](https://github.com/facebookresearch/segment-anything). **The specific code for this post can be found at [scripts/amg.py]**(https://github.com/facebookresearch/segment-anything/blob/main/scripts/amg.py).


## Background

Here we can think first, **how does SAM get a mask with a prompt**, either boxes or points? 

- It uses an image encoder to embed the image into a feature space
- Then, it uses the prompt encoder to encode the prompts as well 
- Finally, the embedded image features and prompts are put into a decoder to generate a mask. 

To understand it better, a study on SAM model would be pretty helpful. You can have a look at this [blog](/post/sam_1_model).

## Challenge 

After getting to know how SAM segments an image with the help of prompts, let us ask, **what does it do if we do not provide a prompt?** In other words, **how to segment the image if the input is just the image, like a typical segmentation question**. 

To solve this on the SAM model, I think the SAM researchers have considered these two key questions:

1. **How to provide final masks, including the mask for large items and a small one for items pretty far?**
2. **Does it still need a prompt? If so, how to provide a prompt for various scaled masks?**


## Solution 

### Crop N Layers 
For multi-scaled masks, it provides an `--crop-n-layers` argument in `amg.py`. If `> 0`, it would give multiple scales. How does it work? Let me explain it. 

For the prompt, the format is (x, y). On `vit-h`, the interval is 1/32, which shows between 0 to 1, there would be 32 intervals. 

When `crop-n-layers = 2`, it would have another prompt points, the interval is 1/16. Its calculation can refer to function: `build_all_layer_point_grids` in [scripts/amg.py](https://github.com/facebookresearch/segment-anything/blob/main/scripts/amg.py). Moreover, it means between 0, 1, there would be 16 intervals. It would be scaled back the image size. Now we can have an impression of how the prompts get created first. 

**For every layer, it creates boxes to crop a single image**. As the layer goes, the box size gets smaller (for quantitative analysis, we can refer to function `generate_crop_boxes` in [scripts/amg.py](https://github.com/facebookresearch/segment-anything/blob/main/scripts/amg.py)), which shows the content of cropped images is less.

Until now, we can see that for every layer in `crop-n-layers`, it would provide the corresponding prompt points and also a box of cropped image. 

The following is a sudo function to generate masks from pair of boxed images and prompt points:

```python
for layer in crop-n-layers:
    for box in boxes:
        cropped_image = image[box]
        for batch in batchize(prompt_points[layer]):
            embedded_image_features = image_encoder(cropped_image)
            embedded_prompt_features = prompt_encoder(batch_prompts)
            mask, iou_prediction = decoder(embedded_image_features, embedded_prompt_features)
            filter_out(mask, iou_prediction)
            concat(mask, iou_prediction) # concat the current results to the previous ones
        filter_out_based_on_nms(mask, iou_predictions)
filter_out_based_on_nms(mask, iou_predictions)
filter_out_the small_region(mask, iou_predictions)
convert_mask_to_certain_format()

```

### Stability Score
On `line 8` in the script [scripts/amg.py](https://github.com/facebookresearch/segment-anything/blob/main/scripts/amg.py), to filter out the raw masks, here the author introduces  `stability_score` concept. 

On `line 300` , this is a Python function called `calculate_stability_score` that takes in three arguments: `masks`, `mask_threshold`, and `threshold_offset`. 

```python
def calculate_stability_score(
    masks: torch.Tensor, mask_threshold: float, threshold_offset: float
) -> torch.Tensor:
    """
    Computes the stability score for a batch of masks. The stability
    score is the IoU between the binary masks obtained by thresholding
    the predicted mask logits at high and low values.
    """
    # One mask is always contained inside the other.
    # Save memory by preventing unnecessary cast to torch.int64
    intersections = (
        (masks > (mask_threshold + threshold_offset))
        .sum(-1, dtype=torch.int16)
        .sum(-1, dtype=torch.int32)
    )
    unions = (
        (masks > (mask_threshold - threshold_offset))
        .sum(-1, dtype=torch.int16)
        .sum(-1, dtype=torch.int32)
    )
    return intersections / unions
```

It returns a tensor containing the stability score for each mask in the batch. the function **compute the intersections and unions of the binary masks**. 

> 1. It first applies **the high threshold** to the masks and sums the resulting binary masks to obtain the intersections. 
> 2. Then it applies **the low threshold** to the masks to obtain the unions. 
> 3. Finally, it computes the stability score as the element-wise division of the intersections and unions. 

However, **it confuses me on the reason of doing filtering based on this score**.


### Filter out Masks Close to Boundaries

Apart from filtering based on `stability_score`, it **filters out masks that touch crop boundaries**. The reason to filter out maskes close to crop boundaries, is to ensure that the predicted masks are accurate and do not contain artifacts or incomplete objects due to the cropping images process. 

> When an image is cropped, it may be partially cut off certain item, which can result in incomplete masks or masks with artifacts. By filtering out the boxes close to crop boundaries, **the model can avoid using these incomplete or artifact-containing masks**, which can improve the overall quality of the predicted masks. 

The function is as following: 

```python
def is_box_near_crop_edge(
    boxes: torch.Tensor, crop_box: List[int], orig_box: List[int], atol: float = 20.0
) -> torch.Tensor:
    """Filter masks at the edge of a crop, but not at the edge of the original image."""
    crop_box_torch = torch.as_tensor(crop_box, dtype=torch.float, device=boxes.device)
    orig_box_torch = torch.as_tensor(orig_box, dtype=torch.float, device=boxes.device)
    boxes = uncrop_boxes_xyxy(boxes, crop_box).float()
    near_crop_edge = torch.isclose(boxes, crop_box_torch[None, :], atol=atol, rtol=0)
    near_image_edge = torch.isclose(boxes, orig_box_torch[None, :], atol=atol, rtol=0)
    near_crop_edge = torch.logical_and(near_crop_edge, ~near_image_edge)
    return torch.any(near_crop_edge, dim=1)
```

### NMS
In NMS, the masks are concated into the previous results. After looping the corresponding batched points on cropped image, it does **filtering from NMS based on IOU score**, the one widely used in the segmentation area. 

If you are not familiar with it, I suggest asking Copilot to get to know it now .


## Remove Small Regions
When loop is done, we can get masks, generated from everywhere of images and its multi-scaled prompts. The small regions using the function `remove_small_regions` [amg.py](https://github.com/facebookresearch/segment-anything/blob/main/segment_anything/utils/amg.py#L267) is the following. 

The `remove_small_regions` function is to remove small regions from the predicted masks.

> It takes in a binary mask as input and removes all connected components that have an area smaller than a specified threshold. The threshold is specified by the `min_size` argument of the function.

```python
def remove_small_regions(mask: np.ndarray, min_size: int) -> np.ndarray:
    """
    Removes small connected components from a binary mask.
    """
    mask = mask.astype(np.uint8)
    num_labels, labels, stats, _ = cv2.connectedComponentsWithStats(mask, connectivity=4)
    sizes = stats[:, -1]
    mask = np.zeros_like(mask)
    for i in range(1, num_labels):
        if sizes[i] >= min_size:
            mask[labels == i] = 1
    return mask
```



The function uses the `connectedComponentsWithStats` function from the OpenCV library to compute the connected components of the binary mask and their corresponding statistics, such as area and centroid. 

Then it iterates over the connected components and removes all components that have an area smaller than the specified `min_size` threshold. Finally, it returns the binary mask with small regions removed.

However, until now, I have failed to understand this concept as well, so open to share!


## Format Masks
Finally, to format the mask, this part tuncrop the boxes into its position on original images: [uncrop_boxes_xyxy](https://github.com/facebookresearch/segment-anything/blob/main/segment_anything/utils/amg.py#L267) and save it to rles format. 

For this part, I am still on reading 


## Final
That's all! Thanks for reading it!
