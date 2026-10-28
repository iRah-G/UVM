/*
Problem:
Write a covergroup that checks whether a 4-bit counter hits all values.

Create bins for:
1. Low  : 0–3
2. Mid  : 4–11
3. High : 12–15
*/

logic       clk;
logic [3:0] counter;

covergroup counter_cg @(posedge clk);

  // Checks the three counter ranges
  counter_range_cp: coverpoint counter {
    bins low  = {[0:3]};
    bins mid  = {[4:11]};
    bins high = {[12:15]};
  }

  // Checks that every individual value from 0 to 15 is hit
  counter_values_cp: coverpoint counter {
    bins all_values[] = {[0:15]};
  }

endgroup

counter_cg cg_counter = new();

/*
### 2. Transition Coverage

Write a covergroup that covers the following state transitions:

1. IDLE  -> READ
2. IDLE  -> WRITE
3. READ  -> IDLE
4. WRITE -> IDLE
5. Any valid state -> ERROR
*/

typedef enum logic [1:0] {
  IDLE  = 2'b00,
  READ  = 2'b01,
  WRITE = 2'b10,
  ERROR = 2'b11
} state_t;

logic   clk;
state_t state;

covergroup state_cg @(posedge clk);

  state_cp: coverpoint state {
    // 1. IDLE -> READ
    bins idle_to_read  = (IDLE => READ);

    // 2. IDLE -> WRITE
    bins idle_to_write = (IDLE => WRITE);

    // 3. READ -> IDLE
    bins read_to_idle  = (READ => IDLE);

    // 4. WRITE -> IDLE
    bins write_to_idle = (WRITE => IDLE);

    // 5. Any valid state -> ERROR
    // Uses the wildcard array syntax to cover [IDLE, READ, WRITE] => ERROR
    bins any_to_error  = ([IDLE, READ, WRITE] => ERROR);
  }

endgroup

state_cg cg_state = new();

/*
3. Cross Coverage

Write a covergroup for a bus transaction.

Create:
1. Bins for each operation
2. Bins for each response
3. Cross coverage between operation and response
*/

typedef enum logic [1:0] {
  OP_IDLE  = 2'b00,
  OP_READ  = 2'b01,
  OP_WRITE = 2'b10,
  OP_ATOMIC = 2'b11
} operation_t;

typedef enum logic [1:0] {
  RESP_OKAY    = 2'b00,
  RESP_ERROR   = 2'b01,
  RESP_RETRY   = 2'b10,
  RESP_TIMEOUT = 2'b11
} response_t;

logic       clk;
operation_t operation;
response_t  response;

covergroup transaction_cg @(posedge clk);

  operation_cp: coverpoint operation {
    // Add operation bins here
  }

  response_cp: coverpoint response {
    // Add response bins here
  }

  operation_response_cross: cross operation_cp, response_cp;

endgroup

transaction_cg cg_transaction = new();
```

---

### 4. Conditional Coverage Using `iff`

```systemverilog
/*
Problem:
Cover an 8-bit data signal only when valid is high.

Create bins for:
1. Zero       : 0
2. Low        : 1–85
3. Medium     : 86–170
4. High       : 171–254
5. Maximum    : 255
*/

logic       clk;
logic       valid;
logic [7:0] data;

covergroup data_cg @(posedge clk);

  data_cp: coverpoint data iff (valid) {
    // Add data bins here
  }

endgroup

data_cg cg_data = new();
```

---

### 5. `ignore_bins` and `illegal_bins`

```systemverilog
/*
Problem:
A 4-bit packet type has the following values:

1. Valid    : 0–9
2. Reserved : 10–13
3. Illegal  : 14–15

Create:
- Separate bins for valid packet types
- ignore_bins for reserved values
- illegal_bins for illegal values
*/

logic       clk;
logic [3:0] packet_type;

covergroup packet_cg @(posedge clk);

  packet_type_cp: coverpoint packet_type {
    // Add valid bins here

    // Add ignore_bins here

    // Add illegal_bins here
  }

endgroup

packet_cg cg_packet = new();
```

---

### 6. Wildcard Bins and Cross Coverage

```systemverilog
/*
Problem:
An instruction has a 4-bit opcode and a 2-bit privilege level.

Opcode categories:
1. Arithmetic : 00xx
2. Logical    : 01xx
3. Memory     : 10xx
4. Control    : 11xx

Privilege levels:
1. User       : 00
2. Supervisor : 01
3. Machine    : 11
4. Reserved   : 10

Create:
- Wildcard bins for opcode categories
- Bins for privilege levels
- An ignore bin for the reserved privilege level
- Cross coverage between opcode and privilege level
*/

logic       clk;
logic [3:0] opcode;
logic [1:0] privilege;

covergroup instruction_cg @(posedge clk);

  opcode_cp: coverpoint opcode {
    // Add wildcard opcode bins here
  }

  privilege_cp: coverpoint privilege {
    // Add privilege bins here

    // Ignore the reserved privilege value
  }

  opcode_privilege_cross: cross opcode_cp, privilege_cp;

endgroup

instruction_cg cg_instruction = new();
```

