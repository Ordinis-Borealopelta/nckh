# nckh

Monorepo microservice cho dự án nckh. Quản lý bởi Ordinis-Borealopelta.

## Kiến trúc

Dự án này tuân theo kiến trúc microservice sử dụng Git submodules. Mỗi service nằm trong repository riêng và có thể deploy độc lập, đồng thời được tích hợp tại đây để phát triển và điều phối local.

```text
                                     +----------------+
                                     |  Frontend      |
                                     |  (Next.js)     |
                                     +-------+--------+
                                             |
                                             v
                                     +-------+--------+
                                     |  Gateway       |
                                     |  (Port 3000)   |
                                     +-------+--------+
                                             |
            +--------------------------------+--------------------------------+
            |                                |                                |
    +-------+--------+               +-------+--------+               +-------+--------+
    |  Auth Service  |               |  Academic      |               |  Certification |
    |  (Port 4000)   |               |  (Port 4001)   |               |  (Port 4002)   |
    +-------+--------+               +-------+--------+               +-------+--------+
                                             |
                                     +-------+--------+
                                     |  Shared Utils  |
                                     |  (Library)     |
                                     +----------------+
```

## Công nghệ sử dụng

- **Runtime**: Bun
- **Framework**: Hono (Services), Next.js (Frontend)
- **Linting/Formatting**: Biome
- **Git Hooks**: Lefthook
- **Ngôn ngữ**: TypeScript

## Các Services

| Service | Thư mục | Port | Mô tả |
|---------|---------|------|-------|
| **Gateway** | `services/gateway` | 3000 | Điểm vào chính. Proxy `/api/auth/*` đến Auth service. |
| **Auth** | `services/auth` | 4000 | Quản lý xác thực sử dụng better-auth với JWT. |
| **Academic** | `services/academic` | 4001 | Quản lý hồ sơ học thuật (Placeholder). |
| **Certification** | `services/certification` | 4002 | Xử lý chứng chỉ (Placeholder). |
| **Frontend** | `frontend/web` | - | Ứng dụng web Next.js. |

### Shared Utilities

Thư mục `services/shared` chứa code và tiện ích dùng chung. Đây không phải là service chạy độc lập mà là thư viện được sử dụng bởi các service khác. Có thể thêm vào bất kỳ service nào bằng cách:

```bash
bun add shared@git+ssh://git@github.com:Ordinis-Borealopelta/shared-service.git#main
```

## Hướng dẫn cài đặt

### Yêu cầu

- Đã cài đặt Bun runtime
- Git được cấu hình với SSH access đến các repository của tổ chức

### Cài đặt

1. Clone repository cùng với tất cả submodules:

   ```bash
   git clone --recurse-submodules git@github.com:Ordinis-Borealopelta/nckh.git
   ```

2. Khởi tạo từng service:

   ```bash
   cd services/<tên-service>
   bun install
   bunx lefthook install
   ```

### Chạy Local

Để khởi động service ở chế độ development:

```bash
bun run dev
```

## Các Scripts

Mỗi service hỗ trợ các scripts sau:

| Script | Mô tả |
|--------|-------|
| `bun run dev` | Khởi động service ở chế độ watch |
| `bun run start` | Khởi động service ở chế độ production |
| `bun run typecheck` | Kiểm tra TypeScript types |
| `bun run lint` | Chạy Biome linting |
| `bun run format` | Format code với Biome |
| `bun run format-and-lint` | Format và lint cùng lúc |

## Health Checks

Mỗi service đều có endpoint `/health`. Gateway service tổng hợp trạng thái của tất cả services tại `/health`.

Ví dụ response từ Gateway `/health`:

```json
{
  "status": "ok",
  "services": {
    "auth": { "status": "ok", "latency": 12 },
    "academic": { "status": "ok", "latency": 8 },
    "certification": { "status": "ok", "latency": 10 }
  }
}
```
