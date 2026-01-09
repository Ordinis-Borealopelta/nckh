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
            |                                |                                |
            +--------------------------------+--------------------------------+
                                             |
                                     +-------+--------+
                                     |   PostgreSQL   |
                                     |  (Multi-schema)|
                                     +----------------+
```

## Công nghệ sử dụng

- **Runtime**: Bun
- **Framework**: Hono (Services), Next.js (Frontend)
- **Database**: PostgreSQL với Drizzle ORM
- **Authentication**: Better-Auth
- **Linting/Formatting**: Biome
- **Git Hooks**: Lefthook
- **Ngôn ngữ**: TypeScript

## Các Services

| Service | Thư mục | Port | Schema | Mô tả |
|---------|---------|------|--------|-------|
| **Gateway** | `services/gateway` | 3000 | - | Điểm vào chính. Proxy requests đến các services. |
| **Auth** | `services/auth` | 4000 | `public` | Quản lý xác thực sử dụng Better-Auth với JWT. |
| **Academic** | `services/academic` | 4001 | `academic` | Quản lý khóa học, lớp học, sinh viên, giảng viên. |
| **Certification** | `services/certification` | 4002 | `certification` | Quản lý văn bằng, chứng chỉ, sổ gốc (Thông tư 21/2019). |
| **Frontend** | `frontend/web` | - | - | Ứng dụng web Next.js. |

## Database Schema

### Auth Service (public schema)
- `user`, `session`, `account`, `verification`, `jwks`
- `organization`, `member`, `invitation`

### Academic Service (academic schema)
- `courses` - Chương trình đào tạo
- `classes` - Lớp học phần
- `enrollments` - Ghi danh học viên
- `waitlist` - Danh sách chờ (tuyển sinh cuốn chiếu)
- `lecturers` - Thông tin giảng viên
- `students` - Thông tin học viên

### Certification Service (certification schema)
- `registry_book` - Sổ gốc cấp văn bằng
- `certificate_types` - Loại chứng chỉ
- `certificate_blanks` - Phôi bằng
- `certificates` - Văn bằng đã cấp
- `certificate_correction_log` - Nhật ký chỉnh sửa
- `graduation_decisions` - Quyết định tốt nghiệp
- `blank_inventory_log` - Nhật ký xuất nhập phôi

### Shared Utilities

Thư mục `services/shared` chứa code và tiện ích dùng chung. Đây không phải là service chạy độc lập mà là thư viện được sử dụng bởi các service khác. Có thể thêm vào bất kỳ service nào bằng cách:

```bash
bun add shared@git+ssh://git@github.com:Ordinis-Borealopelta/shared-service.git#main
```

## Hướng dẫn cài đặt

### Yêu cầu

- Đã cài đặt Bun runtime
- Git được cấu hình với SSH access đến các repository của tổ chức
- PostgreSQL database

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

3. Cấu hình database:

   ```bash
   cp .env.example .env
   # Chỉnh sửa DATABASE_URL trong .env
   ```

4. Chạy migrations:

   ```bash
   bunx drizzle-kit migrate
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

## Database Commands

| Command | Mô tả |
|---------|-------|
| `bunx drizzle-kit generate` | Tạo migration files |
| `bunx drizzle-kit migrate` | Chạy migrations |
| `bunx drizzle-kit push` | Push schema trực tiếp (dev only) |
| `bunx drizzle-kit studio` | Mở Drizzle Studio GUI |

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
