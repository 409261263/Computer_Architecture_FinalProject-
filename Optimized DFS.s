.data
# 5x5 adjacency matrix for the graph
adj_matrix:
.word 0,1,1,0,0 # node 0's connections
.word 1,0,1,0,0 # node 1's connections
.word 1,1,0,1,1 # node 2's connections
.word 0,0,1,0,0 # node 3's connections
.word 0,0,1,0,0 # node 4's connections
visited: .word 0,0,0,0,0 # visited array
msg1: .string "DFS starting from node: "
arrow: .string " -> "
newline: .string "\n"

.text
.global main
main:
    # Print start message
    la a0, msg1
    li a7, 4
    ecall
    
    # Print starting node (1)
    li a0, 1
    li a7, 1
    ecall
    la a0, newline
    li a7, 4
    ecall
    
    # Initialize visited array
    la t0, visited
    sw zero, 0(t0)
    sw zero, 4(t0)
    sw zero, 8(t0)
    sw zero, 12(t0)
    sw zero, 16(t0)
    
    # Start optimized DFS from node 1
    li a0, 1
    jal optimized_dfs
    
    # Print final newline
    la a0, newline
    li a7, 4
    ecall
    
    # Exit program
    li a7, 10
    ecall

# Optimized DFS implementation
# a0: current node
optimized_dfs:
    # Save return address and s registers
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    # Save current node in s0
    mv s0, a0
    
    # Mark as visited and print current node
    la t0, visited
    slli t1, s0, 2
    add t1, t0, t1
    li t2, 1
    sw t2, 0(t1)        # Mark visited
    
    mv a0, s0           # Print node
    li a7, 1
    ecall
    
    # Initialize neighbor counter
    li s1, 0            # Current neighbor
    
check_neighbors:
    li t0, 5
    beq s1, t0, dfs_return  # If checked all neighbors, return
    
    # Load adjacency info (cached in register)
    la t0, adj_matrix
    li t1, 20           # 5 nodes * 4 bytes
    mul t1, s0, t1      # Row offset
    add t0, t0, t1
    slli t1, s1, 2      # Column offset
    add t0, t0, t1
    lw t2, 0(t0)        # Load edge value
    
    # If no edge or already visited, skip
    beqz t2, next_neighbor
    
    # Check if neighbor is visited (reuse previously loaded visited array address)
    la t0, visited
    slli t1, s1, 2
    add t1, t0, t1
    lw t2, 0(t1)
    bnez t2, next_neighbor
    
    # Found unvisited neighbor - print arrow and visit
    la a0, arrow
    li a7, 4
    ecall
    
    # Recursively visit neighbor
    mv a0, s1
    jal optimized_dfs
    
next_neighbor:
    addi s1, s1, 1
    j check_neighbors
    
dfs_return:
    # Restore registers and return
    lw s2, 0(sp)
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret
