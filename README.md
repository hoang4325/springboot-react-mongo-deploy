# Spring Boot + React + MongoDB Fullstack Application

Dự án mẫu triển khai ứng dụng quản lý học sinh (Student Management) sử dụng mô hình Fullstack, hỗ trợ chạy Docker Compose và tích hợp sẵn CI/CD Jenkins.

---

## 🛠️ Công Nghệ Sử Dụng

### Backend
- **Java 8** & **Spring Boot (v2.2.6)**
- **Spring Data MongoDB** (Tương tác NoSQL MongoDB)
- **Spring Boot Actuator** (Monitoring & Health Check)
- **Lombok** & **Maven**

### Frontend
- **React (v18.3)**
- **React Router DOM (v5)** & **Axios** (Kết nối API)
- **Bootstrap (v5)**
- **Nginx** (Web Server chạy Production Build)

### DevOps & Infrastructure
- **MongoDB 5.0**
- **Docker & Docker Compose**
- **Jenkins Pipeline** (CI/CD tự động hóa build/deploy)

---

## 📂 Cấu Trúc Thư Mục

```bash
├── cicd-using-jenkins/          # Các file Jenkinsfile/Groovy cấu hình CI/CD
├── react-student-management/    # Mã nguồn Frontend React
├── spring-boot-student-app-api/ # Mã nguồn Backend Spring Boot
├── docker-compose.yaml          # File chạy cụm dịch vụ qua Docker
└── README.md                    # Hướng dẫn dự án
```

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Dự Án

### Cách 1: Chạy bằng Docker Compose (Khuyên dùng)
Yêu cầu hệ thống đã cài đặt **Docker** và **Docker Compose**.

1. Khởi động toàn bộ ứng dụng (Database, API, Web):
   ```bash
   docker-compose up --build -d
   ```
2. Truy cập ứng dụng:
   - **Frontend UI**: [http://localhost:3000](http://localhost:3000)
   - **Backend API**: [http://localhost:8080](http://localhost:8080)
   - **MongoDB Port**: `27017`

---

### Cách 2: Chạy Thủ Công (Development Mode)

#### 1. Khởi chạy Database
Chạy MongoDB local tại port `27017`.

#### 2. Khởi chạy Backend API
1. Truy cập thư mục backend:
   ```bash
   cd spring-boot-student-app-api
   ```
2. Build và khởi chạy Spring Boot:
   ```bash
   ./mvnw spring-boot:run
   ```

#### 3. Khởi chạy Frontend React
1. Truy cập thư mục frontend:
   ```bash
   cd react-student-management
   ```
2. Cấu hình địa chỉ API bằng cách sửa file `.env`:
   ```env
   REACT_APP_API_URL=http://localhost:8080
   ```
3. Cài đặt thư viện và chạy:
   ```bash
   npm install   # hoặc yarn install
   npm start     # hoặc yarn start
   ```

---

## 🔄 CI/CD Jenkins Pipeline

Thư mục `cicd-using-jenkins` chứa 2 file cấu hình Job Jenkins tự động hóa:
- **`backend-job.groovy`**: Tự động Maven build, build Docker image của API và triển khai.
- **`frontend-job.groovy`**: Tự động Yarn/NPM build, đóng gói ứng dụng React qua Nginx Docker container và triển khai.
