Ran baseline v2 on the cleaned dataset split (same seed family as last week).

Configuration summary:
- Encoder: 6 layers, hidden size 384, 6 attention heads
- Optimizer: AdamW, lr = 2e-4, cosine decay
- Batch size: 64
- Gradient clipping: 1.0

Results:
- Best validation F1: 0.781 (up from 0.754)
- Time to convergence: 11 epochs (down from 16)
- Failure mode: under-predicts minority labels after epoch 8

Takeaway: the scheduler change appears to help convergence speed, but class imbalance remains unresolved.

#experiments #results #baseline #evaluation

TODO: Add focal loss variant and compare minority class recall.
