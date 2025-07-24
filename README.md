# Merkle Tree 实现

[English](README_en.md) | 简体中文

一个基于MoonBit语言的高效Merkle树实现，支持创建树、生成证明和验证证明等功能，可用于数据完整性验证和区块链应用。

## 🌟 核心功能

• 🔐 **哈希函数封装** – 支持自定义哈希函数，默认使用keccak256  
• 📊 **处理输入数据** – 接收任意类型的数据数组，支持字符串、整数等  
• 🍃 **叶节点生成** – 对每个数据计算哈希值，形成树的叶节点  
• 🌲 **递归构建父节点** – 从叶节点开始自动构建完整的树结构  
• 📜 **成员资格证明生成** – 生成单个或多个叶子节点的证明路径  
• ✅ **证明验证** – 验证单个或多个叶子节点的证明有效性  
• 🔄 **支持奇数节点** – 自动处理奇数个节点的情况  
• 🛠️ **自定义哈希** – 支持自定义叶子哈希和节点哈希函数

## 📥 安装与配置

```bash
# 克隆仓库
git clone https://github.com/0Ayachi0/MerkleTree.git

# 进入项目目录
cd MerkleTree

# 编译项目
moonc build

# 运行测试
moonc test
```

## 🚀 使用指南

### 🔨 创建Merkle树

可以使用预定义函数快速创建字符串或整数的Merkle树：

```moonbit
// 创建字符串Merkle树
let values = ["apple", "banana", "cherry", "date"]
let tree = create_string_tree(values)

// 创建整数Merkle树
let numbers = [1, 2, 3, 4, 5]
let int_tree = create_int_tree(numbers)

// 检查树的大小
assert_eq!(length(tree), 4)
assert_eq!(length(int_tree), 5)
```

### 🔍 验证元素

验证元素是否在树中，并且证明是否有效：

```moonbit
// 获取元素的索引
let index = get_value_index(tree, "cherry")
assert_eq!(index, 2)  // "cherry"在索引2的位置

// 验证元素存在性（在实际应用中，proof应该是从树中获取的）
let proof = [] // 简化示例，实际应用需要正确的证明
let is_valid = verify_string_in_tree(tree, "apple", proof)
```

### 📜 多重证明

同时验证多个元素的存在性：

```moonbit
// 创建多重证明
let multi_proof = MultiProof::{
  leaves: ["apple", "cherry"],
  proof: [], // 在实际应用中，这应该是从树中生成的证明
  proof_flags: [true] // 在实际应用中，这应该是从树中生成的标记
}

// 验证多重证明
let is_multi_valid = verify_multi(tree, multi_proof)
```

### 🛠️ 自定义哈希函数

使用自定义哈希函数创建更专业的Merkle树：

```moonbit
// 自定义叶子哈希函数
let custom_leaf_hash = fn(s : String) -> HexString {
  // 自定义哈希逻辑
  keccak256(abi_encode(["string", "uint256"], [s, "1"], fn(s : String) -> String { s }))
}

// 使用自定义哈希函数创建树
let custom_tree = create_tree(values, custom_leaf_hash)
```

### 🔄 获取树的根哈希

获取Merkle树的根哈希，用于验证整个树的完整性：

```moonbit
// 获取根哈希
let root_hash = root(tree)
println("Merkle树根哈希: " + root_hash)

// 使用根哈希验证元素
let is_valid = verify_with_root(
  "apple", 
  proof, 
  root_hash, 
  hash_string
)
```

### 📊 树的基本操作

检查树的基本属性和操作：

```moonbit
// 检查树是否为空
let is_empty = is_empty(tree)
assert_false!(is_empty)

// 获取特定索引的值
let value = value_at(tree, 0)
assert_eq!(value, "apple")

// 获取树的字符串表示
let tree_str = to_string(tree, fn(s) { "\"" + s + "\"" })
println(tree_str)
```

## 📋 完整API参考

### 核心函数
- `create_tree(values, leaf_hash, node_hash)` - 创建Merkle树
- `root(tree)` - 获取树的根哈希
- `length(tree)` - 获取树的大小
- `is_empty(tree)` - 检查树是否为空
- `value_at(tree, index)` - 获取指定索引的值

### 证明相关
- `verify(tree, value, proof)` - 验证单个证明
- `verify_with_root(value, proof, root, leaf_hash)` - 使用根哈希验证证明
- `verify_multi(tree, multi_proof)` - 验证多重证明
- `verify_multi_with_root(multi_proof, root, leaf_hash)` - 使用根哈希验证多重证明

### 辅助函数
- `create_string_tree(values)` - 创建字符串Merkle树
- `create_int_tree(values)` - 创建整数Merkle树
- `hash_string(s)` - 字符串哈希函数
- `hash_int(n)` - 整数哈希函数
- `to_string(tree, value_to_string)` - 获取树的字符串表示

## 📊 性能特性

| 操作 | 时间复杂度 | 空间复杂度 |
|-----|----------|----------|
| 创建树 | O(n log n) | O(n) |
| 获取根哈希 | O(1) | O(1) |
| 验证证明 | O(log n) | O(log n) |
| 验证多重证明 | O(m log n) | O(m + log n) |

其中，n是树中元素的数量，m是多重证明中元素的数量。

## 🏗️ 实现细节

本Merkle树实现基于以下核心组件：

- **叶子哈希函数**：将输入数据转换为固定长度的哈希值
- **节点哈希函数**：将两个子节点的哈希值组合并哈希
- **树结构**：使用数组存储所有节点，便于快速访问
- **证明生成**：为每个叶子节点生成从叶子到根的路径
- **证明验证**：通过重新计算哈希值验证证明的有效性

### 高级特性
- **类型安全**：通过泛型支持任意可哈希类型
- **自定义哈希**：支持自定义哈希函数
- **多重证明**：支持同时验证多个元素
- **奇数节点处理**：自动处理奇数个节点的情况

## 🔍 示例文件

项目包含两个主要示例文件：

- `simple.mbt`：展示基本的Merkle树操作
- `standard.mbt`：展示标准Merkle树操作

## 🧪 测试

项目包含多个测试文件，确保实现的正确性：

- `bytes_test.mbt`：测试字节处理功能
- `hashes_test.mbt`：测试哈希函数
- `MerkleTree_test.mbt`：测试Merkle树功能

运行测试：

```bash
moonc test
```

## 📚 应用场景

- **区块链**：验证交易是否包含在区块中
- **分布式数据库**：验证数据完整性
- **P2P网络**：高效验证数据一致性
- **内容寻址存储**：验证内容完整性
- **零知识证明**：作为零知识证明系统的组件

## 📜 许可证

本项目采用 Apache-2.0 许可证。详见 LICENSE 文件。

## 📢 联系与支持

• MoonBit社区：moonbit-community  
• GitHub Issues：[报告问题](https://github.com/0Ayachi0/MerkleTree/issues)

👋 如果您喜欢这个项目，请给它一个⭐！祝编码愉快！🚀