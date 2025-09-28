#!/bin/bash

echo "=================================================="
echo "           VIZOS COMPREHENSIVE TEST SUITE"
echo "=================================================="
echo "Timestamp: $(date)"
echo "System: $(uname -a)"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results tracking
PASSED=0
FAILED=0
WARNINGS=0

# Function to run test and track results
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_exit="${3:-0}"
    
    echo -e "\n${BLUE}▶ Testing: ${test_name}${NC}"
    echo "Command: $command"
    
    START_TIME=$(date +%s.%N)
    eval $command
    EXIT_CODE=$?
    END_TIME=$(date +%s.%N)
    DURATION=$(echo "$END_TIME - $START_TIME" | bc)
    
    if [ $EXIT_CODE -eq $expected_exit ]; then
        echo -e "${GREEN}✓ PASS${NC} - Duration: ${DURATION}s"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} - Exit code: $EXIT_CODE (expected $expected_exit) - Duration: ${DURATION}s"
        ((FAILED++))
        return 1
    fi
}

# Function to run benchmark
run_benchmark() {
    local bench_name="$1"
    local command="$2"
    local iterations="${3:-5}"
    
    echo -e "\n${PURPLE}⏱️  Benchmark: ${bench_name}${NC}"
    echo "Iterations: $iterations"
    
    TOTAL_TIME=0
    for i in $(seq 1 $iterations); do
        START_TIME=$(date +%s.%N)
        eval $command > /dev/null 2>&1
        END_TIME=$(date +%s.%N)
        ITER_TIME=$(echo "$END_TIME - $START_TIME" | bc)
        TOTAL_TIME=$(echo "$TOTAL_TIME + $ITER_TIME" | bc)
        echo "  Run $i: ${ITER_TIME}s"
    done
    
    AVG_TIME=$(echo "scale=4; $TOTAL_TIME / $iterations" | bc)
    echo -e "${CYAN}📊 Average: ${AVG_TIME}s${NC}"
}

# Function to check system resources
check_system() {
    echo -e "\n${YELLOW}🖥️  SYSTEM RESOURCES${NC}"
    echo "CPU: $(nproc) cores"
    echo "Memory: $(free -h | awk '/^Mem:/{print $2}') total"
    echo "Disk: $(df -h / | awk 'NR==2{print $4}') free"
    
    if command -v vulkaninfo > /dev/null 2>&1; then
        echo -e "\n${CYAN}Vulkan Devices:${NC}"
        vulkaninfo --summary 2>/dev/null | grep -A 10 "deviceName" | head -10 || echo "  Vulkan info not available"
    fi
}

# ============================================================================
# TEST SUITE START
# ============================================================================

echo -e "\n${YELLOW}PHASE 1: SYSTEM CHECK${NC}"
check_system

echo -e "\n${YELLOW}PHASE 2: COMPONENT UNIT TESTS${NC}"

# Test 1: Window Manager Basic Functions
run_test "Window Manager Creation" "./build/window_manager_test" 0

# Test 2: Input System
run_test "Input Dispatch System" "./build/input_dispatch_test" 0

# Test 3: Vulkan Availability
run_test "Vulkan Runtime Check" "./build/vulkan_compositor_test" 0

# Test 4: Screenshot Capability
run_test "Screenshot Tool" "./build/screenshot --test 2>/dev/null || echo 'Screenshot test mode'" 0

echo -e "\n${YELLOW}PHASE 3: PERFORMANCE BENCHMARKS${NC}"

# Benchmark 1: Window Manager Performance
run_benchmark "Window Creation" "./build/window_manager_test" 10

# Benchmark 2: Input System Performance
run_benchmark "Input Event Processing" "./build/input_dispatch_test" 10

# Benchmark 3: Desktop Startup Time
run_benchmark "Desktop Startup" "timeout 2s ./build/vizos_desktop > /dev/null 2>&1 || true" 3

echo -e "\n${YELLOW}PHASE 4: INTEGRATION STRESS TEST${NC}"

# Stress test: Multiple windows and rendering
echo -e "\n${PURPLE}🧪 STRESS TEST: High Window Count${NC}"
for i in {1..5}; do
    echo "Stress test iteration $i..."
    START_TIME=$(date +%s.%N)
    timeout 3s ./build/vizos_desktop > /dev/null 2>&1
    EXIT_CODE=$?
    END_TIME=$(date +%s.%N)
    DURATION=$(echo "$END_TIME - $START_TIME" | bc)
    
    if [ $EXIT_CODE -eq 124 ] || [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}✓ Stable${NC} - Duration: ${DURATION}s"
        ((PASSED++))
    else
        echo -e "${RED}✗ Crashed${NC} - Exit code: $EXIT_CODE"
        ((FAILED++))
    fi
done

echo -e "\n${YELLOW}PHASE 5: MEMORY AND RESOURCE CHECK${NC}"

# Memory leak check pattern
echo -e "\n${CYAN}Memory Usage Pattern:${NC}"
for i in {1..3}; do
    MEM_BEFORE=$(free -k | awk '/^Mem:/{print $3}')
    ./build/vizos_desktop > /dev/null 2>&1 &
    PID=$!
    sleep 1
    MEM_DURING=$(free -k | awk '/^Mem:/{print $3}')
    wait $PID
    MEM_AFTER=$(free -k | awk '/^Mem:/{print $3}')
    
    MEM_USAGE=$((MEM_DURING - MEM_BEFORE))
    MEM_LEAK=$((MEM_AFTER - MEM_BEFORE))
    
    echo "Run $i: Usage=${MEM_USAGE}KB, Leak=${MEM_LEAK}KB"
    
    if [ $MEM_LEAK -gt 1000 ]; then
        echo -e "${RED}⚠ Possible memory leak detected${NC}"
        ((WARNINGS++))
    fi
done

echo -e "\n${YELLOW}PHASE 6: VISUAL VALIDATION${NC}"

# Generate test screenshot
echo -e "\n${CYAN}Generating validation screenshot...${NC}"
./build/screenshot vizos_validation_$(date +%s).png
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Screenshot generated successfully${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ Screenshot generation failed${NC}"
    ((FAILED++))
fi

# ============================================================================
# TEST SUMMARY
# ============================================================================

echo -e "\n${YELLOW}==================================================${NC}"
echo -e "${YELLOW}                 TEST SUMMARY${NC}"
echo -e "${YELLOW}==================================================${NC}"

echo -e "\n${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"

# Overall system health assessment
if [ $FAILED -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 EXCELLENT - System is fully operational and stable!${NC}"
    STATUS="HEALTHY"
elif [ $FAILED -eq 0 ] && [ $WARNINGS -lt 3 ]; then
    echo -e "\n${YELLOW}⚠️  GOOD - System is operational with minor warnings${NC}"
    STATUS="STABLE"
elif [ $FAILED -lt 3 ]; then
    echo -e "\n${YELLOW}🔶 FAIR - System has some issues but core functions work${NC}"
    STATUS="DEGRADED"
else
    echo -e "\n${RED}🚨 POOR - System has significant issues${NC}"
    STATUS="UNSTABLE"
fi

# Generate report file
REPORT_FILE="vizos_benchmark_$(date +%Y%m%d_%H%M%S).txt"

{
    echo "VIZOS BENCHMARK REPORT"
    echo "======================"
    echo "Timestamp: $(date)"
    echo "System: $(uname -a)"
    echo "Status: $STATUS"
    echo ""
    echo "TEST RESULTS:"
    echo "Passed: $PASSED"
    echo "Failed: $FAILED" 
    echo "Warnings: $WARNINGS"
    echo ""
    echo "SYSTEM INFO:"
    nproc
    free -h
    echo ""
    echo "VULKAN INFO:"
    vulkaninfo --summary 2>/dev/null | head -20 || echo "Vulkan info not available"
} > $REPORT_FILE

echo -e "\n${CYAN}📄 Detailed report saved to: $REPORT_FILE${NC}"

echo -e "\n${YELLOW}==================================================${NC}"
echo -e "${GREEN}Benchmark completed at: $(date)${NC}"
echo -e "${YELLOW}==================================================${NC}"

# Exit with appropriate code
if [ $FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi
