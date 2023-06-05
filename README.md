# monolayer_transmigration

Developed by Bernhard Hochreiter 2022
Published under GNU GPL 3.0

When measured in phase contract, roundish cells that migrate through, or sit either below or on top of a homogenous monolayer of cells, look distinctively different due to their stronger contrast. They feature a bright ring surrounding a dark spot, which appear different depending on where they are locate in relation to the focused layer. The developed macro detects these features first by intensity thresholding, and then categorizes their position in relation to the monolayer by the ratio of dark and bright pixels within the detected features.

The user input consists of limits for object size and circularity, the amount of dilations (increasing object size) and erosions (reducing object size) that are used to smoothen and correct object outlines, and the threshold of the fraction of bright pixels (FoBP) that is used to categorize position. These values depend on the used equipment and experiment, and have to be iteratively optimized in a pre-experiment step.

As output, the macro provides an image with an overlay of the detected objects and their categorization as well as a list of all detected objects and their respective measured values, especially the fraction of bright pixels (FoBP) which can be used to categorize cells more or less restrictively.
