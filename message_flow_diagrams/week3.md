```mermaid
sequenceDiagram
    Docker Container->>HTTPoison Process: SSE Stream
    HTTPoison Process->>Reader: AsyncChunk Message
    Reader->>Load Balancer: Parsed Json
    Load Balancer->>Printer: Parsed Json & Message Ref
    Printer->>Worker Speculator: Check Message Ref
    Worker Speculator->>Printer: :ok | :late
```

```mermaid
sequenceDiagram
    WorkerManager->>WorkerManager: Check Worker Stats
```