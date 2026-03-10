Finished a close read of Vaswani et al. (2017). The central claim still holds up:
self-attention is enough to model long-range structure while staying parallelizable.

Observations from this pass:
- Multi-head attention is less about "more attention" and more about representational diversity.
- Residual pathways and layer normalization are carrying more of the optimization burden than I had assumed.
- Positional encoding creates an inductive bias, but the fixed sinusoidal form likely limits adaptation in domain-shift settings.

I want to test whether rotary or learned positional variants improve sample efficiency on my sequence labeling setup.

#reading #papers #transformers #attention #nlp

TODO: Re-derive scaled dot-product attention in matrix form from scratch.
TODO: Run a tiny ablation on head count vs validation stability.
