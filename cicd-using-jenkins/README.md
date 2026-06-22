# Hướng dẫn Cấu hình CI/CD trên Jenkins

Tài liệu này hướng dẫn bạn cách thiết lập Jenkins để chạy tự động hai pipeline CI/CD cho Backend (Spring Boot) và Frontend (React) trong repository này.

---

## 1. Yêu cầu Hệ thống (Prerequisites)
Để Jenkins chạy được các Job này, Server Jenkins cần được cài đặt sẵn:
- **Git**: Để pull code.
- **Docker & Docker Compose**: Để build image và deploy.
- **Quyền Docker**: User chạy Jenkins (thường là `jenkins`) phải thuộc group `docker` để chạy được lệnh `docker` không cần `sudo`.
  ```bash
  sudo usermod -aG docker jenkins
  sudo systemctl restart jenkins
  ```

---

## 2. Tạo Credentials trên Jenkins

Để push Docker image lên Docker Hub (hoặc Private Registry), bạn cần cấu hình thông tin đăng nhập trong Jenkins:

1. Truy cập **Jenkins Dashboard** -> **Manage Jenkins** -> **Credentials**.
2. Chọn domain **(global)** -> ấn **Add Credentials**.
3. Điền các thông tin:
   - **Kind**: `Username with password`
   - **Scope**: `Global`
   - **Username**: Tài khoản Docker Hub của bạn.
   - **Password**: Docker Hub Access Token (Khuyên dùng) hoặc Password của bạn.
   - **ID**: Điền chính xác là `docker-hub-credentials` (phải trùng với biến `REGISTRY_CREDS` trong file `.groovy`).
   - **Description**: Mô tả (ví dụ: Docker Hub login creds).
4. Ấn **Create**.

---

## 3. Tạo Jenkins Job (Pipeline)

Bạn cần tạo 2 Pipeline Job riêng biệt cho Backend và Frontend.

### Bước A: Tạo Job Backend
1. **Jenkins Dashboard** -> **New Item**.
2. Đặt tên Job: `student-app-backend`.
3. Chọn **Pipeline**, ấn **OK**.
4. Di chuyển xuống phần **Pipeline**:
   - **Definition**: Chọn `Pipeline script from SCM`.
   - **SCM**: Chọn `Git`.
   - **Repository URL**: Nhập URL Git Repository của bạn.
   - **Credentials**: Chọn Credentials Github của bạn (nếu là repo private).
   - **Branch Specifier**: Điền branch của bạn (ví dụ: `*/main` hoặc `*/master`).
   - **Script Path**: Điền `cicd-using-jenkins/backend-job.groovy`.
5. Ấn **Save**.

### Bước B: Tạo Job Frontend
1. Làm tương tự Bước A.
2. Đặt tên Job: `student-app-frontend`.
3. Trong phần **Pipeline**:
   - Thiết lập SCM giống như trên.
   - **Script Path**: Điền `cicd-using-jenkins/frontend-job.groovy`.
4. Ấn **Save**.

---

## 4. Cách thức hoạt động của Pipeline

1. **Checkout**: Lấy code mới nhất từ Git repo.
2. **Build**:
   - Backend: Dùng Maven build file JAR (`mvnw clean package`).
   - Frontend & Backend: Dùng Docker build image mới với Tag bằng `${BUILD_NUMBER}` và `${latest}`.
3. **Push**: Login vào Docker Hub thông qua Credentials Jenkins đã tạo, sau đó push image.
4. **Deploy**: Restart service tương ứng thông qua Docker Compose local trên Server Jenkins.
