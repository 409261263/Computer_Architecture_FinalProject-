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

# Start DFS from node 1
li a0, 1
jal dfs

# Print final newline
la a0, newline
li a7, 4
ecall

# Exit program
li a7, 10
ecall

# DFS function
dfs:
# Save return address and s0-s2
addi sp, sp, -16
sw ra, 12(sp)
sw s0, 8(sp)
sw s1, 4(sp)
sw s2, 0(sp)

# Save current node in s0
mv s0, a0

# Check if already visited
la t0, visited
slli t1, s0, 2
add t1, t0, t1
lw t2, 0(t1)
bnez t2, dfs_return # if already visited, return

# Mark as visited
li t2, 1
sw t2, 0(t1)

# Print current node
mv a0, s0
li a7, 1
ecall

# Set up for neighbor checking
mv s1, zero # Initialize neighbor counter
li s2, 0    # Flag to track if we found any unvisited neighbors

check_neighbors:
li t0, 5
beq s1, t0, after_neighbors # If checked all neighbors, go to after_neighbors

# Calculate address of current edge in adjacency matrix
la t0, adj_matrix
li t1, 20 # 5 nodes * 4 bytes per row
mul t1, s0, t1 # Get row offset
add t0, t0, t1 # Get row address
slli t1, s1, 2 # Get column offset
add t0, t0, t1 # Get edge address
lw t1, 0(t0) # Load edge value

# If no edge to this neighbor, skip
beqz t1, next_neighbor

# Check if neighbor is unvisited
la t0, visited
slli t1, s1, 2
add t0, t0, t1
lw t1, 0(t0)
bnez t1, next_neighbor # If visited, skip

# Print arrow before visiting new node
la a0, arrow
li a7, 4
ecall

# Visit neighbor through recursive call
mv a0, s1
li s2, 1    # Set flag indicating we found an unvisited neighbor
jal dfs

next_neighbor:
addi s1, s1, 1 # Increment neighbor counter
j check_neighbors

after_neighbors:
beqz s2, dfs_return  # If no unvisited neighbors were found, return without printing arrow

dfs_return:
# Restore saved registers
lw s2, 0(sp)
lw s1, 4(sp)
lw s0, 8(sp)
lw ra, 12(sp)
addi sp, sp, 16
ret
