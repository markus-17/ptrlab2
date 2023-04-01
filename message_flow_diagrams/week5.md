```mermaid
sequenceDiagram
    participant Docker Container
    participant HTTPoison Process
    participant Reader
    participant Load Balancer
    participant Retweet Handler
    participant Formatter
    participant Sentiment Scorer
    participant Engagement Ratio Scorer
    participant Reducer
    participant Batcher

    Docker Container->>HTTPoison Process: SSE Stream
    HTTPoison Process->>Reader: AsyncChunk Message
    Reader->>Load Balancer: Parsed Json
    
    Load Balancer->>Retweet Handler: Parsed Json
    Retweet Handler->>Load Balancer: Extracted Retweet

    Load Balancer->>Formatter: Parsed Json
    Formatter->>Reducer: Formatted Text

    Load Balancer->>Sentiment Scorer: Parsed Json
    Sentiment Scorer->>Reducer: Computed Sentiment Score

    Load Balancer->>Engagement Ratio Scorer: Parsed Json
    Engagement Ratio Scorer->>Reducer: Computed Engagement Ratio Score & User Id

    Reducer->>Batcher: Matching Set
```