```mermaid
sequenceDiagram
    Docker Container->>HTTPoison Process: SSE Stream
    HTTPoison Process->>Reader: AsyncChunk Message
    Reader->>Load Balancer: Parsed Json
    Load Balancer->>Printer: Parsed Json
```