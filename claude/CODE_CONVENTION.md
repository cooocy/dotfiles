# Java 项目代码规范（通用）

> 适用于所有 Java 后端项目

---

## 1. 分层架构

```
src/main/java/com/xxx/xxx/
├── domain/              # 领域层：实体、值对象、仓储接口、领域服务
│   ├── packages/
│   │   ├── Package.java
│   │   ├── PackageRepository.java
│   │   └── PackageType.java
│   └── ...
├── application/         # 应用层：AppService、Assembler、RO、VO
│   ├── service/         # 应用服务
│   ├── assembler/       # DO ↔ VO 组装器
│   ├── arv/
│   │   ├── ro/          # Request Object 请求对象
│   │   └── vo/          # View Object 响应对象
│   └── eventbus/        # 事件
├── infrastructure/      # 基础设施层：RepositoryImpl、PO、Mapper、RPC
│   ├── repositoryimpl/
│   ├── rpc/
│   ├── kits/            # 工具类
│   └── config/
└── interfaces/          # 接口层：Controller
    └── http/
        ├── api/         # 对外 API
        └── inner/       # 内部 RPC
```

---

## 2. DDD 核心原则

### 2.1 Domain 层
- **只包含纯业务逻辑**，不依赖外部服务
- Entity 使用**构造函数/工厂方法**创建，禁止直接 new 后 set
- **不要在 Domain 中放静态工具方法**，移至 Application Service

### 2.2 Repository
- 接口放在 `domain` 包
- 实现放在 `infrastructure/repositoryimpl` 包
- 方法命名：`save`, `findById`, `findAll`, `lock`（for update）

### 2.3 Application Service
- 编排业务逻辑，调用 Domain 和 Repository
- **事务边界**放在 AppService 层
- 不要在此层写业务逻辑，委托给 Domain

---

## 3. 命名规范

| 类型 | 命名规则 | 示例 |
|------|----------|------|
| Entity | 业务名词 | `Package`, `Order` |
| Value Object | 业务名词，无 ID | `PricingStrategy`, `TimeRange` |
| Repository 接口 | `XxxRepository` | `PackageRepository` |
| Repository 实现 | `XxxRepositoryImpl` | `PackageRepositoryImpl` |
| PO (持久化对象) | `XxxPO` | `PackagePO` |
| Mapper | `XxxPOMapper` | `PackagePOMapper` |
| AppService | `XxxAppService` | `PackageAppService` |
| Assembler | `XxxAssembler` | `PackageAssembler` |
| Controller | `XxxApiController` / `XxxInnerController` | `PackageApiController` |
| RO | `XxxRO` | `CreatePackageRO` |
| VO | `XxxVO` | `PackageVO` |

---

## 4. 异常处理

### 4.1 统一使用 BizException
```java
throw new BizException(Codes.ArgsIllegal, "参数错误");
throw new BizException(CodeAndMessage.RecordNotFound);
```

### 4.2 定义业务错误码
在 `CodeAndMessage` 枚举中统一管理

### 4.3 安全原则
**禁止通过接口探测用户是否存在**，用户不存在时返回与业务失败相同的错误码：
```java
// 错误示例
user.orElseThrow(() -> new BizException(Codes.ArgsIllegal, "用户不存在"));

// 正确示例
user.orElseThrow(() -> new BizException(CodeAndMessage.LampOilInsufficient));
```

---

## 5. 代码风格

- 单个方法不超过 **50 行**
- 使用 `CollUtil.isEmpty()` 判断空集合（Hutool）
- 同一逻辑出现 **3 次**以上必须提取
- // 注释，“//” 后空格，使用中文汉字和英文标点

---

## 6. 技术债务

- **TODO 不超过 20 个**，每个必须有明确处理计划
- **@Deprecated 标记后 1 个月内清理**
- 禁止提交包含 `// TODO: fixme` 的代码

---

## 7. Git 提交规范

### 7.1 Commit Message
```
<type>: <简短描述>

<详细描述>
```

Type:
- `feat`: 新功能
- `fix`: Bug 修复
- `refactor`: 重构
- `docs`: 文档
- `test`: 测试
- `chore`: 构建/依赖

### 7.2 分支命名
- `feature/xxx`
- `bugfix/xxx`
- `refactor/xxx`

---

## 8. 常用依赖

- **Lombok**：减少样板代码
- **Hutool**：工具类集合
- **MyBatis-Plus**：持久化框架
- **Spring Framework**：DI/AOP