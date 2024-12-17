---

# **Integration of Data Cache in a Pipelined RISC-V Processor (RI5CY)**

## **Overview**
This project focuses on designing and integrating a parameterized, high-performance, set-associative data cache into the RI5CY core, a 4-stage, open-source, pipelined RISC-V processor. The goal is to enhance processor performance by minimizing memory access latency, thereby reducing pipeline stalls and improving throughput.

---

## **Table of Contents**
1. [Abstract](#abstract)  
2. [Introduction](#introduction)  
3. [Project Objectives](#project-objectives)  
4. [RI5CY Core Overview](#ri5cy-core-overview)  
5. [Data Cache Design and Implementation](#data-cache-design-and-implementation)  
6. [Simulation and Testing](#simulation-and-testing)  
7. [Performance Analysis](#performance-analysis)  
8. [Conclusion](#conclusion)  
9. [References](#references)  

---

## **Abstract**  
This project aims to enhance the performance of the RI5CY processor by integrating a 32 KB, 4-way set-associative data cache. The cache incorporates advanced features like a Least Recently Used (LRU) replacement policy and a write-through policy. Simulations and testing validate the integration, and benchmarks demonstrate the cache's impact on processor performance.

---

## **Introduction**  
Data caches play a critical role in improving processor performance by storing frequently accessed data closer to the processor. In pipelined architectures like RI5CY, memory access delays can lead to pipeline stalls. Integrating a data cache minimizes these delays, increasing throughput and addressing a key limitation of pipelined processors.  

This project targets the design and integration of a data cache with the load/store unit of the RI5CY core, reducing memory latency and optimizing processor performance.

---

## **Project Objectives**  
- Design a 32 KB, 4-way set-associative data cache with LRU and write-through policies.  
- Integrate the cache with the load/store unit of the RI5CY core.  
- Perform simulations and benchmark performance improvements.  

---

## **RI5CY Core Overview**  
The RI5CY core is a 4-stage, in-order, 32-bit processor based on the RV32IMC instruction set architecture. Key components include the instruction fetch (IF), instruction decode (ID), instruction execute (IX), and write-back (WB) stages. The load/store unit (LSU) is responsible for memory operations, supporting various data types and misaligned memory accesses.  

The RI5CY core supports:  
- **RV32I**: Base integer instruction set for 32-bit processors.  
- **RV32C**: Compressed instructions.  
- **RV32M**: Integer multiplication and division extensions.  

---

## **Data Cache Design and Implementation**  

### **Key Features**  
- **Capacity**: 32 KB, divided into 512 sets with 4 blocks per set.  
- **Associativity**: 4-way set associative.  
- **Replacement Policy**: LRU to manage cache line replacements.  
- **Write Policy**: Write-through for data coherency.  
- **Parameterized Design**: Cache size, associativity, and block size are configurable.  

### **Architecture**  
The cache design consists of:  
1. **Cache Memory Module**: Handles data storage and retrieval.  
2. **LRU Module**: Tracks usage patterns to determine which data to replace.  
3. **Cache Controller**: Manages communication between the cache, load/store unit, and main memory.  
4. **Top Module**: Integrates all components and facilitates communication with the RI5CY core.

![Top_Block_Diagram drawio](https://github.com/user-attachments/assets/9910f561-dbf3-41b2-947c-0933b097964d)


### **Cache Controller FSM**  
The controller operates in seven states:  
1. **IDLE**: Waits for a request.  
2. **HIT_CHECK**: Determines cache hit or miss.  
3. **MISS**: Handles cache misses.  
4. **FETCH_1 - FETCH_4**: Fetches data from main memory.  

---

## **Simulation and Testing**  
- **Unit Testing**: Validates individual modules such as LRU and cache memory.  
- **Pipeline Testing**: Verifies full integration with the RI5CY core, including the load/store unit and main memory.  
- **Testbench Scenarios**: Simulated cache hits, misses, read/write operations, and replacement cases.

---

## **Performance Analysis**  
A benchmark was developed to evaluate the cache's performance. Initial results indicate reduced pipeline stalls and improved throughput when using the cache compared to relying solely on main memory.

---

## **Conclusion**  
This project successfully integrated a 32 KB data cache into the RI5CY core, significantly reducing memory access delays and improving processor performance. Future work could explore multi-level caches and advanced replacement policies for further optimization.

---

## **References**  
- RI5CY GitHub Repository: [RI5CY Core](https://github.com/pulp-platform/riscv)  
- Technical Manuals and Documentation on RISC-V ISA.  

---
