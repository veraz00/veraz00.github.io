---
layout: post
title: "Create Synthetic Dataset"
subtitle: "Create Synthetic Dataset"
category: engineer
tags: pixel 
---

{:toc}


# Background 
Why do I create synthetic dataset? 
- Synthetic data is a wide-used solution given the challenges and importance of **“edge cases”** in the world.  It provides a **diverse dataset** that is essential for enhancing the performance of AI models. 
    1. The original dataset may lack images from different weather conditions, including shade on sunny days, snowy backgrounds, or raining crops.  
    2. Collecting real-world data for all weather scenarios may not be feasible, and instead, a synthetic dataset can generate the necessary volume of data for efficiently training AI models to handle **unexpected real scenarios**. 

- In addition to providing a diverse dataset, synthetic data has other benefits, including **cost reduction, increased accuracy in data labeling**, since labels in synthetic data are already known, and **scalability**, as datasets can be developed based on specific needs.

# Github
- [Synthetic_Dataset](https://github.com/veraz00/Synthetic_Dataset)

# Preaparation 
- Add original implement images  
    Here I used implement images. For every image, it has its corresponding **YOLO Darknet TXT** labelling file   
    ```
    # image1.txt
    1 0.408 0.30266666666666664 0.104 0.15733333333333333
    1 0.245 0.424 0.046 0.08 
    ```    
    ```
    # object.name
    drawbar
    mower_landpride_rcr
    mower_tierre_1_lupo
    wood_trailer
    ```
- Add other files into repo. Project structure is the following
    ```
    create_synthetic_dataset
    ├── main.ipynb
    ├── labelled_test
    │   ├──image1.png
    │   ├──image1.txt
    │   ├──...
    ├── source
    │   ├── background
    │   │   ├──bg1.png
    │   │   ├──...
    │   ├── bg_noise
    │   │   ├── images
    |   │   │   ├──nosie1.png
    |   │   │   ├──...
    │   │   └── masks
    │   └── combined
    └── U-2-Net
        └── model
    ```
    - For **original images (and labels)**, which would be used to generate the synthetic dataset, are put into the `labelled_test` folder. These labelled objects will be extracted and used to create synthetic images.
    - For **backgrounds**, which are downloaded online and are put into `source/background` folder 
    - For **noise items**, like cars, or farm utilities, which will be used into image generations as well, they are put into `source/bg_noise/images` folder, along with their corresponding masks in the `source/bg_noise/masks folder`
        - For noise images, it would only have noise item on the image, check [example](https://github.com/veraz00/Synthetic_Dataset/tree/main/source/bg_noise)
        - Masks of noise items can be generated using **Steps-3** method

# Steps 
1. Crop detected part based on labelling file on original images
    - Inaccurate bounding boxes that do not closely match the detected object are permissible in this case, as the code has been designed to **generate precise bounding boxes**
    ```
    for ff in glob.glob(original_images + '/*.png'):
        img = cv2.imread(ff) # h, w, 3
        h, w, _ = img.shape
        h_o = float(h)
        w_o = float(w)

        basename = os.path.basename(ff)[:-4]
        txt_ff = os.path.join(original_images, basename + '.txt')
        with open (txt_ff, 'r') as f:  # rough bounding box
            for num, line in enumerate(f.readlines()):
                c, x_ct, y_ct, w, h = line.split(' ')
                if c == '0': # ignore tractor connector part 
                    continue
                temp_name = f'{basename}_{num}_{c}.png'
                y1 = int(h_o * (float(y_ct) - float(h)/2))
                y2 = int(h_o * (float(y_ct) + float(h)/2))
                x1 = int(w_o * (float(x_ct) - float(w)/2))
                x2 = int(w_o * (float(x_ct) + float(w)/2))
                temp_img = img[y1:y2, x1:x2]
                cv2.imwrite(os.path.join(new_folder, temp_name), temp_img)
    ```
    - The following is example of input and output  

    | Input/Image | Output/Detected Part |
    |:----------:|------------|
    |![](/assets/imgs/2022-04-23/orange_mower_copied.jpg)|![](/assets/imgs/2022-04-23/cropped_orange_mower_copied.jpg)|
    <!-- <img src="/assets/imgs/2022-04-23/orange_mower.png" width="200" height="100"> | <img src="/imgs/2022-04-23/cropped_orange_mower.jpg" width="200" height="100">   -->

2. Use **U^2-net** to get mask of detected part  
    I used the small size of `U2-Net`(4.7 MB, 40 FPS) model to generate mask. The reason to use detected part is that it only includes the implement, not other noise items, which would be important when generating **accurate** bounding box on step 3 
    ```
    !python -W ignore u2net_test.py
    ```
    | Input/Detected Part| Output/Mask |
    |:----------:|------------|
    |![](/assets/imgs/2022-04-23/cropped_orange_mower_copied.jpg)|![](/imgs/2022-04-23/mask_orange_mower_copied.jpg)|
    <!-- | <img src="/assets/imgs/2022-04-23/cropped_orange_mower.jpg" width="200" height="100"> | <img src="/imgs/2022-04-23/mask_orange_mower.png" width="200" height="100"> |  -->

3. **Shrink bounding boxes based from masks** 
    Based on pixels value on mask, it can be used to generate the bounding box. 
    - To figure out the precise bounding box, it is equal to generate the left-upper and right-botton corner of bounding box
    - Since the background is **black pixels (0, 0, 0)** and detected object part is **white pixels (1, 1, 1)**, from the left to right and upper to bottom in the maskm (x, y) of left upper corner of the bounding box would be the position of the first white pixel, similarly, the right bottom corner of the bounding box would be the position of last white pixel of the mask. Based on this method, it correctly identifies the bounding box around the rectangle of white pixels.

    ```
    for ff_l in glob.glob('implements_m/*.png'):
        basename = os.path.basename(ff_l)
        img_l = cv2.imread(ff_l)  # h, w, 3

        img = cv2.imread(f'implements/{basename}')

        # BOUNDING BOX CREATION
        out_layer = img_l[:,:,LAYER]
        x_starts = [np.where(out_layer[i]==1)[0][0] if len(np.where(out_layer[i]==1)[0])!=0 else out_layer.shape[0]+1 for i in range(out_layer.shape[0])]
        x_ends = [np.where(out_layer[i]==1)[0][-1] if len(np.where(out_layer[i]==1)[0])!=0 else 0 for i in range(out_layer.shape[0])]
        y_starts = [np.where(out_layer.T[i]==1)[0][0] if len(np.where(out_layer.T[i]==1)[0])!=0 else out_layer.T.shape[0]+1 for i in range(out_layer.T.shape[0])]
        y_ends = [np.where(out_layer.T[i]==1)[0][-1] if len(np.where(out_layer.T[i]==1)[0])!=0 else 0 for i in range(out_layer.T.shape[0])]
        
        startx = min(x_starts)
        endx = max(x_ends)
        starty = min(y_starts)
        endy = max(y_ends)

        img_l = img_l[starty:endy, startx:endx, :]
        img = img[starty:endy, startx:endx, :]

        cv2.imwrite(f'implements_l/{basename}', img_l)
        cv2.imwrite(f'implements/{basename}', img)
    ```
    
4. Apply augmentation into cropped parts, background, noise items separately 
    Here the synthetic dataset is aim to enrich the cases under multiple weather conditions. Thus, I applied mutliple weather conversion using `albumentation` package on it
    - For implement images, I added **noise, blur, fog, shadow (2-5 pieces) and changed brightness**

    ```
    import albumentations as A

    transform_implement = A.Compose([
        A.OneOf([
            A.IAAAdditiveGaussianNoise(),
            A.GaussNoise(),
        ], p=0.5),
        A.OneOf([
            A.MotionBlur(p=.2),
            A.MedianBlur(blur_limit=3, p=0.2),
            A.Blur(blur_limit=3, p=0.2),
        ], p=0.5),
        A.VerticalFlip(p=0.1),              
        A.RandomRotate90(p=0.1),
        A.RandomBrightnessContrast(p=0.2),
        A.RandomFog(fog_coef_lower=0.3, fog_coef_upper=1, p=0.2),
        A.RandomShadow (shadow_roi=(0, 0, 1, 1), num_shadows_lower=1, \
        num_shadows_upper=2, shadow_dimension=5, always_apply=False, p=1),
        
    ])
    ```
    - For background, rain, sun, noise, blur and others are applied  
    ```
    transform_background = A.Compose([
        A.OneOf([
            A.IAAAdditiveGaussianNoise(),
            A.GaussNoise(),
        ], p=0.5),
        A.OneOf([
            A.MotionBlur(p=.2),
            A.MedianBlur(blur_limit=3, p=0.1),
            A.Blur(blur_limit=3, p=0.1),
        ], p=0.2),
        A.OneOf([
            A.CLAHE(clip_limit=2),
            A.IAASharpen(),
            A.RandomBrightnessContrast(),            
        ], p=0.3),
        A.RGBShift(r_shift_limit=25, g_shift_limit=25, b_shift_limit=25, p=0.5),
        A.RandomBrightnessContrast(brightness_limit=0.3, contrast_limit=0.3, p=0.5),
        A.HueSaturationValue(p=0.3),
        A.CLAHE(p=0.8),
        A.RandomGamma(p=0.8),
        A.OneOf([
            A.RandomRain(p=0.5),
            A.RandomSunFlare(p=0.5)
        ], p =0.8)
    ])
    ```

5. After this, all augmented crops parts (implements) and noise items are added into augmented backgrounds  
    - To prevent **overlapping of items when placing them onto backgrounds**, I've employed a `check_areas` function to ensure their positions do not overlap
    ```
    def check_areas(mask_1, mask_2, threshold=0.4):  # x1, y1, w1, h1-- implement; (x2, y2, w2, h2) -- mask
        # check if 2 mask has overlap > threshold
        _, x1, y1, w1, h1 = mask_1
        _, x2, y2, w2, h2 = mask_2 
        xx1 = np.maximum(x1, x2)
        yy1 = np.maximum(y1, y2)
        xx2 = np.minimum(x1+w1, x2+w2)
        yy2 = np.minimum(y1+h1, y2+h2)

        # Find out the width and the height of the intersection box
        w = np.maximum(0, xx2 - xx1 + 1)
        h = np.maximum(0, yy2 - yy1 + 1)
        
        # compute the ratio of overlap
        overlap = (w * h) / (w1*h1 + w2 * h2 - w * h)
        # if the actual boungding box has an overlap bigger than treshold with any other box, remove it's index  
        if np.any(overlap) > threshold:
            return False
        return True 

    ```
    - Finally, combine all the parts into backgrounds
    ```
    def cumulate_images(count_implement, implements_path, noise = False):
        # input: number of implements/noise items; they can be added to background 
        # output: images_masks-- a list = [[cls_index, implement, implement_mask],,]
        images_masks = []
        for _ in range(count_implement):
            implement_path = np.random.choice(implements_path)
            implement = cv2.imread(implement_path)
        
            basename = os.path.basename(implement_path)[:-4]
            if noise == False:
                cls_index = basename[-1]
            else:
                cls_index = '-1'  # for noise
            implement_mask_path = re.sub('images', 'masks', implement_path)
            implement_mask = cv2.imread(implement_mask_path, 0)
            images_masks.append([cls_index, implement, implement_mask])  # inside is white
        return images_masks


    def combined(images_masks, aug_bg):
        # input: 
        # images = [[c, img1, mask1], [c, img2, mask2], [c, img3, mask3]], 
        # mask: implement would be 1 

        # output: 
        # combined bg with images_masks
        
        past_box = [] # class, left, upper, w, h  # noise, label = '-1', class is str(index)
        bg_h, bg_w, _ = aug_bg.shape
        func = lambda x, y: check_areas(x, y)

        for cls_index, img, mask_img in images_masks:

            img_h, img_w, _ = img.shape
            if cls_index == '-1':
                img = cv2.resize(img, (300, int(300 * img_w/img_h))) # h, w
                mask_img = cv2.resize(mask_img, (300, int(300 * img_w/img_h)))

            mask_img = mask_img == 0  # (0, 0, 0) is black 
            mask_img = 1 - np.stack([mask_img, mask_img, mask_img], axis = 2)  # np.ones((mask_img.shape[0], mask_img.shape[1], 3))

            if cls_index != '-1':
                augmented = transform_implement(image=img, mask=mask_img)
            else:
                augmented = transform_noise(image = img, mask = mask_img)

            aug_img = augmented['image']
            aug_mask = augmented['mask']    
            img_h, img_w, _ = aug_img.shape

            look = True
            while look:
                y1 = np.random.randint(0, bg_h-img_h)
                x1 = np.random.randint(0, bg_w-img_w)
                new_box = [cls_index, x1, y1, img_w, img_h]
                if len(past_box) > 0:
                    temp_box = [[cls_index, x1, y1, img_w, img_h] for _ in range(len(past_box))]
                    map_result = list(map(func, temp_box, past_box))
                    if False not in map_result: 
                        break
                else:
                    break
            print('cls_index', cls_index)
            aug_bg[y1:y1+img_h, x1:x1+img_w, :] = aug_img * aug_mask + aug_bg[y1:y1+img_h, x1:x1+img_w, :] * (1-aug_mask)

            if cls_index != '-1':
                aug_bg = display_bounding_box(aug_bg, x1, y1, img_w, img_h)
                aug_bg = display_class_name(aug_bg, x1, y1, class_list[int(cls_index)])
            past_box.append(new_box)
        return aug_bg, past_box
    ```

# Result 
- Augmented implement on fake background
    | Mower Tierre Lupo | Mower Landpride Rcr  | Wood Trailer |
    |:----------:|------------|------------|
    | ![](/assets/imgs/2022-04-23/new_pto_1_0_2_copied.jpg) | ![](/assets/imgs/2022-04-23/new_pto_4_0_1_copied.jpg) | ![](/assets/imgs/2022-04-23/new_pto_12_0_3_copied.jpg) |

- Augmented implement with **noise items** on fake background
    | Mower Tierre Lupo | Mower Landpride Rcr  | Wood Trailer |
    |:----------:|------------|------------|
    | ![](/assets/imgs/2022-04-23/bg11_copied.jpg) | ![](/assets/imgs/2022-04-23/bg1_copied.jpg) | ![](/assets/imgs/2022-04-23/bg14_copied.jpg) |

Although the synthetic data can be successfully generated here, but we can see, actually this synthetic images are not enough realistic. Looking forward for more work would be added on this part! 



# Refer
1. [Medium: How to Create Synthetic Dataset](https://medium.com/@alexppppp/how-to-create-synthetic-dataset-for-computer-vision-object-detection-fd8ab2fa5249)
2. [U^2-net](https://github.com/xuebinqin/U-2-Net)
3. [Guide: Synthetic Data Generation](https://datagen.tech/guides/synthetic-data/synthetic-data-generation/)