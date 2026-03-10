Hypothesis: a staged curriculum for multi-modal fusion will outperform single-stage joint training
when text and image channels have asymmetric noise.

Proposed training stages:
1. Warm-start text encoder on in-domain language objectives.
2. Freeze lower text layers, train visual adapter alignment.
3. Unfreeze full stack for joint optimization with consistency regularization.

What seems promising:
- Should reduce early gradient conflict between modalities.
- Might improve low-resource stability when image labels are sparse.
- Could produce better calibration by delaying hard fusion.

Risks:
- Additional training complexity may erase gains.
- Freezing schedule may over-constrain adaptation.

#ideas #multimodal #curriculum-learning #hypothesis
