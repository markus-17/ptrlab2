```mermaid
sequenceDiagram
    Docker Container->>HTTPoison Process: SSE Stream
    HTTPoison Process->>Reader: AsyncChunk Message
    Reader->>Printer: Parsed Json
    Reader->>HashtagPrinter: Parsed Json
```