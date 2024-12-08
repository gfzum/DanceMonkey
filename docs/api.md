# API文档

## 概述

DanceMonkey API采用RESTful设计，提供了一系列端点用于视频上传、处理和结果获取。所有API端点都以`/api/v1`为前缀，支持跨域请求（CORS）。

## 基础信息

- 基础URL: 
  - 开发环境: `http://localhost:8000`
  - 生产环境: `https://api.dancemonkey.azurewebsites.net`
- API版本: v1
- 响应格式: JSON
- CORS配置: 允许前端域名访问

## 认证

### 会话认证
API使用基于Cookie的会话认证：

1. 登录：
```http
POST /api/auth/login
Content-Type: application/json

{
    "username": "your_username",
    "password": "your_password"
}
```

2. 登出：
```http
POST /api/auth/logout
```

所有API请求会自动使用会话Cookie进行认证，无需额外配置。

## CORS配置

### 允许的源
```python
CORS_ORIGINS = [
    "http://localhost:5173",  # 开发环境
    "https://dancemonkey.azurewebsites.net"  # 生产环境
]
```

### CORS设置
```python
CORS_SETTINGS = {
    "allow_origins": CORS_ORIGINS,
    "allow_credentials": True,
    "allow_methods": ["*"],
    "allow_headers": ["*"]
}
```

## API端点

### 视频管理

#### 上传视频
```http
POST /api/v1/videos
Content-Type: multipart/form-data

{
    "file": <video-file>,
    "title": "string",
    "description": "string"
}
```

**响应**
```json
{
    "task_id": "string",
    "video_id": "string",
    "status": "pending",
    "created_at": "string"
}
```

#### 获取视频信息
```http
GET /api/v1/videos/{video_id}
```

**响应**
```json
{
    "id": "string",
    "title": "string",
    "description": "string",
    "status": "string",
    "created_at": "string",
    "updated_at": "string",
    "duration": "number",
    "file_size": "number",
    "url": "string"
}
```

### 任务管理

#### 获取任务状态
```http
GET /api/v1/tasks/{task_id}
```

**响应**
```json
{
    "task_id": "string",
    "status": "string",
    "progress": "number",
    "message": "string",
    "created_at": "string",
    "updated_at": "string"
}
```

#### 取消任务
```http
POST /api/v1/tasks/{task_id}/cancel
```

**响应**
```json
{
    "task_id": "string",
    "status": "cancelled",
    "message": "string"
}
```

### 分析结果

#### 获取分析结果
```http
GET /api/v1/results/{task_id}
```

**响应**
```json
{
    "task_id": "string",
    "video_id": "string",
    "analysis": {
        "movements": [
            {
                "timestamp": "number",
                "duration": "number",
                "type": "string",
                "confidence": "number",
                "description": "string"
            }
        ],
        "suggestions": [
            {
                "type": "string",
                "description": "string",
                "confidence": "number"
            }
        ]
    },
    "created_at": "string"
}
```

#### 导出结果
```http
POST /api/v1/results/{task_id}/export
Content-Type: application/json

{
    "format": "string"  // "pdf" | "json" | "csv"
}
```

**响应**
```json
{
    "export_id": "string",
    "status": "processing",
    "download_url": "string"
}
```

## 状态码

| 状态码 | 描述 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 请求错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 429 | 请求过多 |
| 500 | 服务器错误 |

## 错误响应

所有错误响应都遵循以下格式：
```json
{
    "error": {
        "code": "string",
        "message": "string",
        "details": {}
    }
}
```

## 数据模型

### Video
```json
{
    "id": "string",
    "title": "string",
    "description": "string",
    "status": "string",
    "created_at": "string",
    "updated_at": "string",
    "duration": "number",
    "file_size": "number",
    "url": "string"
}
```

### Task
```json
{
    "id": "string",
    "video_id": "string",
    "status": "string",
    "progress": "number",
    "message": "string",
    "created_at": "string",
    "updated_at": "string"
}
```

### Analysis
```json
{
    "movements": [
        {
            "timestamp": "number",
            "duration": "number",
            "type": "string",
            "confidence": "number",
            "description": "string"
        }
    ],
    "suggestions": [
        {
            "type": "string",
            "description": "string",
            "confidence": "number"
        }
    ]
}
```

## 限制

- 视频文件大小：最大500MB
- 支持的视频格式：MP4, MOV, AVI
- API请求速率：
  - 认证用户：100次/分钟
  - 未认证用户：10次/分钟
- 并发任务数：每用户最多5个

## WebSocket API

### 任务状态订阅
```
WebSocket: wss://api.dancemonkey.azurewebsites.net/ws/tasks/{task_id}
```

**连接参数**
- `task_id`: 任务ID

**消息格式**
```json
{
    "type": "status_update",
    "data": {
        "task_id": "string",
        "status": "string",
        "progress": "number",
        "message": "string",
        "timestamp": "string"
    }
}
```

### WebSocket客户端示例
```python
import asyncio
import websockets

async def subscribe_task_status(task_id: str):
    uri = f"wss://api.dancemonkey.azurewebsites.net/ws/tasks/{task_id}"
    async with websockets.connect(uri) as websocket:
        while True:
            message = await websocket.recv()
            data = json.loads(message)
            print(f"Received update: {data}")

# 使用示例
asyncio.get_event_loop().run_until_complete(
    subscribe_task_status("task-123")
)
```

### 错误处理
WebSocket连接可能会遇到以下错误：
- 1000: 正常关闭
- 1001: 服务端关闭
- 1006: 异常关闭
- 1011: 服务器错误

建议实现自动重连机制，例如：
```python
async def connect_with_retry(task_id: str, max_retries: int = 5):
    for i in range(max_retries):
        try:
            await subscribe_task_status(task_id)
            break
        except websockets.ConnectionClosed:
            if i == max_retries - 1:
                raise
            await asyncio.sleep(2 ** i)  # 指数退避
```

## 前端集成

### API客户端配置
```typescript
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.VITE_API_URL || 'http://localhost:8000',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  },
  withCredentials: true  // 启用跨域Cookie
});

// 响应拦截器
api.interceptors.response.use(
  response => response.data,
  error => {
    if (error.response?.status === 401) {
      // 未认证，重定向到登录页面
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// API方法
export const api = {
  // 认证
  auth: {
    login: (username: string, password: string) => 
      api.post('/api/auth/login', { username, password }),
    logout: () => api.post('/api/auth/logout'),
  },
  
  // 视频管理
  videos: {
    upload: (file: File, title: string, description: string) => {
      const formData = new FormData();
      formData.append('file', file);
      formData.append('title', title);
      formData.append('description', description);
      return api.post('/api/v1/videos', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
    },
    get: (videoId: string) => api.get(`/api/v1/videos/${videoId}`),
  },
  
  // 任务管理
  tasks: {
    getStatus: (taskId: string) => api.get(`/api/v1/tasks/${taskId}`),
    cancel: (taskId: string) => api.post(`/api/v1/tasks/${taskId}/cancel`),
  },
  
  // 结果管理
  results: {
    get: (taskId: string) => api.get(`/api/v1/results/${taskId}`),
    export: (taskId: string, format: string) => 
      api.post(`/api/v1/results/${taskId}/export`, { format }),
  },
};
```

### WebSocket客户端
```typescript
export class TaskWebSocket {
  private ws: WebSocket;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  
  constructor(taskId: string, onMessage: (data: any) => void) {
    this.connect(taskId, onMessage);
  }
  
  private connect(taskId: string, onMessage: (data: any) => void) {
    const wsUrl = `${process.env.VITE_WS_URL || 'ws://localhost:8000'}/ws/tasks/${taskId}`;
    this.ws = new WebSocket(wsUrl);
    
    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      onMessage(data);
    };
    
    this.ws.onclose = () => {
      if (this.reconnectAttempts < this.maxReconnectAttempts) {
        const timeout = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 10000);
        this.reconnectAttempts++;
        setTimeout(() => this.connect(taskId, onMessage), timeout);
      }
    };
  }
  
  disconnect() {
    this.reconnectAttempts = this.maxReconnectAttempts;  // 防止重连
    this.ws.close();
  }
}

// 使用示例
const taskSocket = new TaskWebSocket('task-123', (data) => {
  console.log('Task update:', data);
});

// 组件卸载时
taskSocket.disconnect();
```

## 版本控制

- 当前版本：v1
- URL前缀：`/api/v1`
- 版本更新策略：
  - 主版本号：不兼容的API更改
  - 次版本号：向后兼容的功能性新增
  - 修订号：向后兼容的问题修复
``` 