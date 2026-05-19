# 手记软件 — 完整产品计划

## 一、产品概述

**产品名称（待定）：Moodiary / 墨记 / SomNote**

一款面向年轻女性用户（18-35岁）的韩系Ins风AI心情手记App，支持图文、语音、链接等多种记录方式，内置AI陪伴助手，每周一自动生成周报关键词回顾。

---

## 二、市场调研

### 2.1 市场规模

| 指标 | 数据 | 来源 |
|------|------|------|
| 数字日记App市场（2025） | **~$60亿美元** | FMI / TBRC |
| 心情追踪App市场（2024） | **$13亿美元** | WiseGuy Reports |
| 市场年复合增长率 | **11.4% ~ 13.1%** | 多方一致 |
| 增长最快区域 | **亚太区（印度13.5%、中国12.8%）** | FMI |
| 移动端占比 | **65%+** | 行业数据 |

### 2.2 主要竞品分析

#### 一梯队：全球领导者

| App | 优势 | 劣势 |
|-----|------|------|
| **Day One** | 功能最全面，E2EE加密，Apple Intelligence集成，10年+品牌沉淀 | 仅订阅制（$35-49/年），AI隐私争议（数据外传OpenAI），界面日趋臃肿，Android端体验差 |
| **Journey** | AI驱动（Odyssey AI/GPT），多模版，跨平台优秀 | 品牌辨识度不如Day One，定价偏高 |
| **Reflectly** | AI引导式心情追踪，对话式交互，年轻人喜爱 | 功能相对单一，深度记录能力弱 |

#### 二梯队：新兴AI选手

| App | 亮点 | 不足 |
|-----|------|------|
| **NeuroTwin** | Whisper语音转文字 + GPT-4视觉识别 + ChromaDB长记忆 | 新产品，用户基数小 |
| **Luminalog** | Notion风格编辑器 + 情感模式分析 + Telegram集成 | 免费版功能受限 |
| **Journalie** | 语音→视觉故事，自动生成独特页面 | 无文字输入选项，仅识别一种情绪 |
| **Heart Stamp** (韩国) | AI复刻韩国老师盖章传统，情感分析 | 功能较单一 |

#### 三梯队：轻量替代

| App | 特点 |
|-----|------|
| **Daylio** | 图标式快速记录，无需打字，情绪趋势图表 |
| **Diaro** | 跨平台，多语言，去中心化存储 |
| **Apple Journal** | 免费，iOS集成，但功能有限 |

### 2.3 市场痛点与机会

| 痛点 | 机会 |
|------|------|
| Day One从买断转订阅，老用户愤怒 | **提供买断+订阅双轨制**，降低用户决策门槛 |
| 隐私焦虑：AI功能将数据外传云端 | **设备端AI优先**（Apple Intelligence / 本地模型），明确数据主权 |
| 功能臃肿：10%的功能被90%用户使用 | **极简设计**，核心流程不超过3步完成记录 |
| 缺乏个性化美学 | **韩系Ins风设计**，区别于现有产品的工具感 |
| Day One Android体验差 | **Flutter跨平台**，iOS/Android一致体验 |
| 周报/回顾功能薄弱 | **AI驱动的每周关键词报告**，可视化情绪趋势 |
| 亚洲市场缺乏本土化 | **中文/韩文/日文优先**，亚洲审美优先 |

---

## 三、竞争优势与劣势分析

### 3.1 优势 (Strengths)

1. **差异化设计**：韩系Ins风美学——玻璃拟态 + 莫兰迪色系 + 手绘感插画，与现有竞品的「工具感」形成鲜明对比
2. **AI周报创新**：每周一自动生成上周关键词云 + 情绪曲线 + AI小结，目前无竞品完整提供此功能
3. **隐私优先**：设备端AI处理优先策略，可成为核心卖点（直接对标Day One的隐私争议）
4. **全媒体记录**：图文 + 语音 + 链接一站式记录，覆盖更多场景
5. **定价灵活性**：买断+订阅双轨制，吸引不同付费意愿的用户群
6. **亚洲市场先发**：中文/韩文/日文优先支持 + 亚洲审美，抢占被忽视的市场
7. **轻量专注**：不堆砌功能，保持核心流程极简，区别于Day One的臃肿

### 3.2 劣势 (Weaknesses)

1. **品牌从零开始**：无用户基础，需要高效获客策略
2. **数据迁移壁垒**：用户已有大量日记在Day One/Journey等平台，迁移成本高
3. **AI成本压力**：GPT-4/Whisper API调用成本，免费方案需要精细控制
4. **团队规模**：初期小团队 vs 竞品Automattic(Day One母公司)等大厂资源
5. **平台生态弱**：无电脑端/平板端/iWatch端，短期内仅移动端
6. **社交传播依赖**：Ins风设计虽美但能否真正驱动UGC传播待验证

### 3.3 机会 (Opportunities)

1. Day One的AI隐私争议正在驱赶用户，可精准承接
2. 亚太区13.5% CAGR是最大增量市场
3. Apple Intelligence / Google Gemini等端侧AI降低服务器成本
4. 小红书/Instagram/TikTok的「手帐」内容生态成熟，病毒传播路径清晰
5. 可穿戴设备数据集成（健康数据自动同步到日记）

### 3.4 威胁 (Threats)

1. Apple Journal持续迭代，可能免费覆盖基础需求
2. Notion/Obsidian等通用工具增加AI日记功能
3. AI API成本长期不可控
4. 日记类App用户粘性虽高但新增获客成本持续上升

---

## 四、功能规划

### 4.1 MVP核心功能（V1.0）

| 模块 | 功能 | 优先级 |
|------|------|--------|
| **记录** | 图文混排记录心情（支持多图上传） | P0 |
| **记录** | 语音转文字记录（Whisper API） | P0 |
| **记录** | 链接嵌入记录（URL预览卡片） | P0 |
| **AI** | 心情/情绪自动分析（NLP情感分类） | P0 |
| **AI** | AI每日一句话回复/共鸣 | P0 |
| **回顾** | 每周一自动生成周报（关键词 + 情绪曲线） | P0 |
| **回顾** | 日历视图，按日期浏览记录 | P0 |
| **基础** | 用户注册/登录（邮箱 + 第三方） | P0 |
| **基础** | 本地+云端数据同步 | P0 |
| **基础** | 应用锁（生物识别/Face ID） | P0 |

### 4.2 V1.5 增强功能

| 模块 | 功能 |
|------|------|
| **记录** | 视频记录（最长60秒） |
| **AI** | AI聊天陪伴（基于日记内容的上下文对话） |
| **AI** | 情绪趋势预测与提醒 |
| **回顾** | 月度/年度回顾报告（可分享的精美卡片） |
| **社交** | 匿名心情社区（可选加入） |
| **个性化** | 主题/贴纸/字体自定义 |

### 4.3 V2.0 进阶功能

| 模块 | 功能 |
|------|------|
| **AI** | 设备端AI模型（Apple Intelligence / Gemini Nano），无需联网 |
| **AI** | 照片自动识别标签（GPT-4 Vision → 本地模型） |
| **健康** | 可穿戴设备数据集成（步数、心率、睡眠同步到日记） |
| **导出** | 精美PDF/实体手帐打印服务 |
| **多端** | iPad / macOS / Web 端 |

---

## 五、UI设计系统

### 5.1 核心设计语言：韩系Ins风 + Calm UX

```
设计关键词：
  玻璃拟态 · 莫兰迪色系 · 大量留白 · 手绘插画
  柔缓动效 · Bento卡片 · 圆角 · 细体字 · 空气感
```

### 5.2 色彩系统

| 用途 | 色值 | 说明 |
|------|------|------|
| 主背景 | `#FAF7F5` | 暖奶油白 |
| 卡片背景 | `rgba(255,255,255,0.7)` + 模糊 | 玻璃拟态 |
| 主色调 | `#C4A89A` | 莫兰迪棕粉 |
| 辅助色1 | `#A3B5C8` | 雾霾蓝 |
| 辅助色2 | `#D4C5BE` | 淡奶茶 |
| 文字主色 | `#4A4A4A` | 深灰（非纯黑） |
| 文字辅色 | `#9A9A9A` | 浅灰 |
| 强调/警示 | `#E8C4B8` | 淡珊瑚 |

### 5.3 关键页面设计

**首页（时间轴）**
- 大卡片瀑布流布局
- 每张卡片为玻璃拟态风格
- 照片以拍立得风格展示（白色边框 + 微阴影）
- 心情以emoji + 柔和色彩标签显示
- 顶部：当前日期 + 天气 + 心情快捷入口

**记录页**
- 全屏沉浸式编辑
- 键盘上方工具栏：照片、语音、链接、贴纸
- 实时AI情感分析指示器（输入时微动效）
- 发布按钮设计为柔和的渐变圆角按钮

**周报页**
- 顶部大标题："你的第X周" + 日期范围
- 关键词云（Bento卡片内，柔和色彩标签）
- 情绪曲线图（平滑渐变面积图）
- AI小结卡片（手写感字体）
- 可分享按钮（生成精美卡片图）

**个人页**
- 头像 + 昵称 + 记录天数/总条目
- 成就徽章（连续记录/情绪稳定等）
- 设置入口（极简列表）

### 5.4 动效规范

| 场景 | 动效 |
|------|------|
| 页面切换 | 柔和渐变过渡（300ms ease-out） |
| 卡片出现 | 从下淡入 + 微上移（staggered） |
| 发布成功 | 轻微弹跳 + 粒子扩散 |
| AI回复 | 打字机逐字出现效果 |
| 下拉刷新 | 呼吸式加载动画 |

---

## 六、技术架构

### 6.1 技术选型

| 层 | 选型 | 理由 |
|----|------|------|
| **跨平台框架** | **Flutter 3.x** | 像素级UI控制、丰富动画能力、iOS/Android一致体验、Reflectly同款技术栈 |
| **后端** | **Supabase** (初期) → 自建 FastAPI (规模化) | 快速启动，自带Auth/Storage/Realtime |
| **数据库** | PostgreSQL (Supabase) | 关系型数据 + JSON字段灵活性 |
| **AI - 语音** | OpenAI Whisper API | 最高准确率，90+语言支持 |
| **AI - 情感分析** | OpenAI GPT-4o-mini | 性价比最高的情感分析 + 多语言 |
| **AI - 视觉** | GPT-4 Vision (图片识别标签) | 自动识别照片内容生成标签 |
| **AI - 端侧(未来)** | Apple Intelligence / Google Gemini Nano | 隐私优先，离线可用 |
| **存储** | Supabase Storage / AWS S3 | 图片/语音文件存储 |
| **推送** | Firebase Cloud Messaging | 周报推送、每日提醒 |
| **分析** | Mixpanel / 自建 | 用户行为分析 |

### 6.2 系统架构图 (文字版)

```
┌─────────────────────────────────────┐
│            Flutter App              │
│  ┌──────────┐  ┌──────────────────┐ │
│  │ UI Layer │  │  Local DB (Hive) │ │
│  │ (Widgets)│  │  (离线缓存)       │ │
│  └────┬─────┘  └──────────────────┘ │
│       │                              │
│  ┌────┴──────────────────────────┐  │
│  │    State Management (Riverpod) │  │
│  └────┬──────────────────────────┘  │
└───────┼──────────────────────────────┘
        │
   HTTPS/REST
        │
┌───────┴──────────────────────────────┐
│          Backend (Supabase)          │
│  ┌────────┐ ┌──────┐ ┌───────────┐  │
│  │  Auth  │ │  DB  │ │  Storage  │  │
│  └────────┘ └──────┘ └───────────┘  │
│         │          │                 │
│    ┌────┴──────────┴────┐           │
│    │   Edge Functions   │           │
│    │  (AI API 调用层)    │           │
│    └────────┬───────────┘           │
└─────────────┼────────────────────────┘
              │
    ┌─────────┴──────────┐
    │   OpenAI API       │
    │  (Whisper/GPT-4)   │
    └────────────────────┘
```

### 6.3 核心数据模型

```
User
  - id, email, nickname, avatar_url
  - created_at, subscription_tier

Entry (日记条目)
  - id, user_id
  - content (text)
  - mood: { emoji, score: 1-5, label }
  - media: [{ type: image|voice|link, url, metadata }]
  - tags: [AI自动生成]
  - is_private: bool
  - created_at, updated_at

AIInteraction
  - id, entry_id, user_id
  - type: sentiment_analysis | reply | suggestion
  - response: text
  - created_at

WeeklyReport
  - id, user_id
  - week_start, week_end
  - keywords: [{ word, weight }]
  - mood_curve: [{ date, score }]
  - ai_summary: text
  - entry_count: int
  - generated_at
```

---

## 七、开发路线图

### Phase 1: 项目初始化（第1-2周）
- [ ] Flutter项目搭建 + 基础架构
- [ ] Supabase项目配置（Auth + DB + Storage）
- [ ] 设计系统落地（颜色/字体/组件库）
- [ ] Figma设计稿定稿（核心页面）

### Phase 2: MVP核心（第3-8周）
- [ ] 用户注册/登录流程
- [ ] 图文记录功能（文本 + 多图上传）
- [ ] 语音转文字记录
- [ ] 链接嵌入记录（URL预览卡片）
- [ ] 时间轴首页（卡片瀑布流）
- [ ] 日历视图

### Phase 3: AI集成（第9-12周）
- [ ] AI情感分析集成
- [ ] AI每日回复功能
- [ ] 关键词提取服务
- [ ] 周报生成服务（定时任务）
- [ ] 周报展示页面

### Phase 4: 打磨与发布（第13-16周）
- [ ] 动效优化与微交互
- [ ] 性能优化（图片懒加载、缓存策略）
- [ ] 内测 + Bug修复
- [ ] App Store / Google Play 上架准备
- [ ] 应用商店截图与文案

---

## 八、商业模式

| 方案 | 价格（参考） | 内容 |
|------|-------------|------|
| **免费版** | ¥0 | 每日3条记录，基础AI分析，1个媒体/条，上周周报 |
| **Pro月订阅** | ¥18/月 | 无限记录，完整AI，9个媒体/条，历史周报，主题 |
| **Pro年订阅** | ¥128/年 | 同月订阅 + 年度回顾报告 |
| **Lifetime买断** | ¥298 | 永久Pro权限（限时销售策略，吸引Day One迁移用户） |

---

## 九、验证方法

### 开发阶段
1. `flutter analyze` — 静态代码检查零报错
2. `flutter test` — 核心业务逻辑单元测试覆盖率 > 80%
3. Widget测试 — 关键页面组件渲染正确
4. 集成测试 — 记录→AI分析→周报 全链路通过
5. 真机测试 — iOS 16+ / Android 13+ 实际设备验证

### 产品验证
1. UI还原度检查 — 对照Figma逐页对比
2. 用户体验测试 — 5人内测小组2周使用反馈
3. AI准确率评估 — 情感分析准确率 > 85%
4. 性能指标 — 冷启动 < 2s，发布记录 < 500ms
5. 崩溃率 — < 0.5%

---

## 十、风险与应对

| 风险 | 概率 | 应对 |
|------|------|------|
| AI API成本超预期 | 中 | 设置免费用户用量上限；优先推动设备端AI；批量API调用优惠 |
| 用户增长缓慢 | 高 | 小红书/Ins KOL种草合作；App Store优化(ASO)；限时Lifetime吸引首波用户 |
| 竞品复制功能 | 高 | 持续迭代速度优势；品牌情感差异化(设计+社区)；迁移成本构建(数据沉淀) |
| Apple Journal挤压 | 中 | 不做Apple能做的通用功能；聚焦「有AI灵魂的陪伴感」而非工具 |
| 隐私合规风险 | 中 | 明确数据使用政策；设备端AI优先；支持数据导出(降低锁定感) |
| 语音识别多语言质量 | 中 | Whisper优先支持中/韩/日/英；逐步优化其他语言 |

---

## 十一、附录

### A. 竞品数据来源
- [Digital Journal Apps Market Report - TBRC](https://www.researchandmarkets.com/reports/6035247/digital-journal-apps-market-report)
- [Digital Journal Apps Market - FMI](https://www.futuremarketinsights.com/reports/digital-journal-apps-market)
- [Mood Tracker App Market - WiseGuy Reports](https://www.wiseguyreports.com/reports/mood-tracker-app-market)

### B. 设计参考
- Apple Liquid Glass 设计语言（WWDC 2025）
- [The Aesthetics of Calm UX - Raw.Studio](https://raw.studio/blog/the-aesthetics-of-calm-ux-how-blur-and-muted-themes-are-redefining-digital-design/)
- 韩国App: Clody, Hidamda, Heart Stamp, DecoDiary

### C. 技术参考
- Reflectly (Flutter开发的日记App先驱)
- NeuroTwin (Whisper + GPT-4 + ChromaDB 技术栈)
- [Flutter vs React Native 2025](https://dev.to/mridudixit15/flutter-vs-react-native-2025-who-wins-the-cross-platform-war-4hfh)
