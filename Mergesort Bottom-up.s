.data
size: 		.word   8
arr: 		.word   7, 4, 10, -1, 3, 2, -6, 9
str1: 		.string " Before Sort : "
str2: 		.string " After Sort  : "
newline: 	.string "\n"
comma:		.string " , "

.text
main:
	addi 	sp, sp, -4
	sw	ra, 0(sp)	
	
	# print str1
	la	a0, str1
	addi 	a7, x0, 4
	ecall

	# print current array
	la	a0, arr
	lw	a1, size
	jal	ra, printArray

	# do iterative MergeSort
	la	a0, arr
	lw	a1, size
	jal	ra, iterativeMergeSort

	# print str2
	la	a0, str2
	addi 	a7, x0, 4
	ecall

	# print sorted array
	la	a0, arr
	lw	a1, size
	jal	ra, printArray
	
	lw	ra, 0(sp)
	addi	sp, sp, 4
	addi    a7, x0, 10
        ecall
        jalr	x0, ra, 0

# Iterative MergeSort
# a0: array address
# a1: array size
iterativeMergeSort:
    addi    sp, sp, -24
    sw      ra, 0(sp)
    sw      s0, 4(sp)      # array address
    sw      s1, 8(sp)      # size
    sw      s2, 12(sp)     # current width
    sw      s3, 16(sp)     # left start
    sw      s4, 20(sp)     # iteration counter
    
    mv      s0, a0         # save array address
    mv      s1, a1         # save size
    
    # Start with merging subarrays of size 1
    addi    s2, x0, 1      # width starts from 1
    
width_loop:
    bge     s2, s1, end_sort   # if width >= size, we're done
    
    # For each width, merge subarrays
    addi    s3, x0, 0      # left = 0
    
left_loop:
    # Calculate right start and end
    add     t0, s3, s2     # mid = left + width
    add     t1, t0, s2     # right_end = mid + width
    
    # Ensure right_end doesn't exceed array size
    bge     t1, s1, adjust_end
    j       do_merge
    
adjust_end:
    mv      t1, s1         # right_end = size
    
do_merge:
    # If there are elements to merge
    bge     s3, t0, next_iteration
    
    # Prepare arguments for merge
    mv      a0, s0         # array address
    mv      a1, s3         # left start
    addi    a2, t0, -1     # mid - 1
    addi    a3, t1, -1     # right_end - 1
    jal     ra, merge
    
next_iteration:
    add     s3, s3, s2     # left += width
    add     s3, s3, s2     # left += width (total: left += 2*width)
    blt     s3, s1, left_loop
    
    # Double the width for next iteration
    add     s2, s2, s2     # width *= 2
    j       width_loop
    
end_sort:
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    lw      s3, 16(sp)
    lw      s4, 20(sp)
    addi    sp, sp, 24
    jalr    x0, ra, 0

# Merge function (same as original)
merge:
    sub     t0, a3, a1
    addi    t0, t0, 1
    add     t1, t0, t0
    add     t1, t1, t1
    xori    t2, t1, 0xffffffff
    addi    t2, t2, 1
    add     sp, sp, t2

    addi    t3, a1, 0
    addi    t2, x0, 0
read2Stack:
    blt     a3, t3, endRead
    add     t4, t3, t3
    add     t4, t4, t4
    add     t4, a0, t4
    lw      t5, 0(t4)
    add     t6, t2, t2
    add     t6, t6, t6
    add     t6, sp, t6
    sw      t5, 0(t6)
    addi    t2, t2, 1
    addi    t3, t3, 1
    j       read2Stack
endRead:

    sub     t4, a2, a1
    sub     t5, a3, a1
    addi    t2, x0, 0
    addi    t3, t4, 1
    addi    t6, a1, 0

mergeLoop:
    slt     t0, t4, t2
    slt     t1, t5, t3
    or      t0, t0, t1
    xori    t0, t0, 0x1
    beq     t0, x0, endMergeLoop
    add     t0, t2, t2
    add     t0, t0, t0
    add     t0, sp, t0
    lw      t0, 0(t0)
    add     t1, t3, t3
    add     t1, t1, t1
    add     t1, sp, t1
    lw      t1, 0(t1)
    blt     t1, t0, rightSmaller
    add     t1, t6, t6
    add     t1, t1, t1
    add     t1, a0, t1
    sw      t0, 0(t1)
    addi    t6, t6, 1
    addi    t2, t2, 1
    j       mergeLoop
rightSmaller:
    add     t0, t6, t6
    add     t0, t0, t0
    add     t0, a0, t0
    sw      t1, 0(t0)
    addi    t6, t6, 1
    addi    t3, t3, 1
    j       mergeLoop
endMergeLoop:

    bge     t5, t3, rightLoop
leftLoop:
    add     t0, t2, t2
    add     t0, t0, t0
    add     t0, sp, t0
    lw      t0, 0(t0)
    add     t1, t6, t6
    add     t1, t1, t1
    add     t1, a0, t1
    sw      t0, 0(t1)
    addi    t6, t6, 1
    addi    t2, t2, 1
    bge     t4, t2, leftLoop
    j       endMerge
rightLoop:
    add     t1, t3, t3
    add     t1, t1, t1
    add     t1, sp, t1
    lw      t1, 0(t1)
    add     t0, t6, t6
    add     t0, t0, t0
    add     t0, a0, t0
    sw      t1, 0(t0)
    addi    t6, t6, 1
    addi    t3, t3, 1
    bge     t5, t3, rightLoop

endMerge:
    sub     t0, a3, a1
    addi    t0, t0, 1
    add     t1, t0, t0
    add     t1, t1, t1
    add     sp, sp, t1
    jalr    x0, ra, 0

# Print Array function (same as original)
printArray:
    addi    t0, a0, 0
    addi    t1, a1, 0
    addi    t2, x0, 0
printLoop:
    add     t3, t2, t2
    add     t3, t3, t3
    add     t3, t0, t3
    lw      a0, 0(t3)
    addi    a7, x0, 1
    ecall
    addi    t2, t2, 1
    bge     t2, t1, endPrint
    la      a0, comma
    addi    a7, x0, 4
    ecall
    j       printLoop
endPrint:
    la      a0, newline
    addi    a7, x0, 4
    ecall
    jalr    x0, ra, 0
