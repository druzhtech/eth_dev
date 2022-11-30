module Lock
    syntax Value   ::= Int  // this can be changed
    syntax Address ::= Int  // this can be changed
    // defining the "syntax" of the contract
    syntax AExp ::= Value | Address
                | "buy" "(" ")"
                | "balanceOf" "(" AExp ")"                       [strict]
                | "throw"
    // configuring cells for the contract's storage
    configuration <lock>
                  <caller> 0 </caller>
                  <value> 0 </value>
                  <k> $PGM:K </k>
                  <accounts>
                    <account multiplicity="*">
                      <id> 0 </id>
                      <balance> 0 </balance>
                    </account>
                  </accounts>
                  <supply> 0 </supply>
                  <hardcap> Int 200 * (Int 10 ^Int 18) </hardcap>
                </lock>
    // balanceOf returns the balance of a given account
    rule <k> balanceOf(Id) => Value ...</k>
       <id> Id </id>
       <balance> Value </balance>
    // The buy function receives ether and distributes tokens appropriately.
    // Requirements:
    // - the buy function has to receive ether, so the value cannot be zero
    // - once the hard cap has been reached, no more tokens can be sold
    rule <k> buy() => .</k>
       <caller> From </caller>
       <value> MsgValue </value>
       <hardcap> HardCap </hardcap>
       <supply> Total => Total +Int MsgValue *Int 2</supply>
       <account>
         <id> From </id>
         <balance> BalanceFrom => BalanceFrom +Int MsgValue *Int 2 </balance>
       </account>
     requires MsgValue >=Int 0
       andBool Total +Int MsgValue *Int 2 <=Int HardCap
endmodule
