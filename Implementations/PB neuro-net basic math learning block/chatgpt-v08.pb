; Step 1: Define Objects and Operations
Structure Operation
  a.i
  b.i
  operator.s
  result.f
EndStructure

Procedure Add(a.i, b.i)
  ProcedureReturn a + b
EndProcedure

Procedure Subtract(a.i, b.i)
  ProcedureReturn a - b
EndProcedure

Procedure Multiply(a.i, b.i)
  ProcedureReturn a * b
EndProcedure

Procedure Divide(a.i, b.i)
  If b <> 0
    ProcedureReturn a / b
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

; Step 2: Generate Training Data
Global Dim odata.Operation(3999)

Procedure GenerateData()
  Protected i.i
  For i = 0 To 999
    odata(i)\a = Random(99) + 1
    odata(i)\b = Random(99) + 1
    odata(i)\operator = "+"
    odata(i)\result = Add(odata(i)\a, odata(i)\b) / 100.0
    
    odata(i + 1000)\a = Random(99) + 1
    odata(i + 1000)\b = Random(99) + 1
    odata(i + 1000)\operator = "-"
    odata(i + 1000)\result = Subtract(odata(i + 1000)\a, odata(i + 1000)\b) / 100.0
    
    odata(i + 2000)\a = Random(99) + 1
    odata(i + 2000)\b = Random(99) + 1
    odata(i + 2000)\operator = "*"
    odata(i + 2000)\result = Multiply(odata(i + 2000)\a, odata(i + 2000)\b) / 10000.0
    
    odata(i + 3000)\a = Random(99) + 1
    odata(i + 3000)\b = Random(99) + 1
    odata(i + 3000)\operator = "/"
    odata(i + 3000)\result = Divide(odata(i + 3000)\a, odata(i + 3000)\b) / 100.0
  Next
EndProcedure

GenerateData()

; Step 3: Implement the Neural Network
Structure NeuralNetwork
  InputNodes.i
  HiddenNodes.i
  OutputNodes.i
  *InputHiddenWeights
  *HiddenOutputWeights
EndStructure

Procedure.f RandomWeight()
  ProcedureReturn (Random(200) - 100) / 100.0
EndProcedure

Procedure InitializeNetwork(*nn.NeuralNetwork, inputNodes.i, hiddenNodes.i, outputNodes.i)
  *nn\InputNodes = inputNodes
  *nn\HiddenNodes = hiddenNodes
  *nn\OutputNodes = outputNodes
  *nn\InputHiddenWeights = AllocateMemory(inputNodes * hiddenNodes * SizeOf(Float))
  *nn\HiddenOutputWeights = AllocateMemory(hiddenNodes * outputNodes * SizeOf(Float))
  
  Protected i.i
  For i = 0 To inputNodes * hiddenNodes - 1
    PokeF(*nn\InputHiddenWeights + i * SizeOf(Float), RandomWeight())
  Next
  
  For i = 0 To hiddenNodes * outputNodes - 1
    PokeF(*nn\HiddenOutputWeights + i * SizeOf(Float), RandomWeight())
  Next
EndProcedure

Procedure.f Sigmoid(x.f)
  ProcedureReturn 1.0 / (1.0 + Exp(-x))
EndProcedure

Procedure.f DotProduct(*a, *b, size.i)
  Protected result.f = 0.0
  Protected i.i
  For i = 0 To size - 1
    result + PeekF(*a + i * SizeOf(Float)) * PeekF(*b + i * SizeOf(Float))
  Next
  ProcedureReturn result
EndProcedure

Procedure ForwardPass(*nn.NeuralNetwork, *inputs.Float, *hiddenOutputs.Float, *finalOutput.Float)
  Protected i.i, j.i
  Protected temp.f

  ; Calculate hidden layer outputs
  For i = 0 To *nn\HiddenNodes - 1
    temp = 0.0
    For j = 0 To *nn\InputNodes - 1
      temp + PeekF(*inputs + j * SizeOf(Float)) * PeekF(*nn\InputHiddenWeights + (j * *nn\HiddenNodes + i) * SizeOf(Float))
    Next
    PokeF(*hiddenOutputs + i * SizeOf(Float), Sigmoid(temp))
  Next
  
  ; Calculate final output
  temp = 0.0
  For i = 0 To *nn\HiddenNodes - 1
    temp + PeekF(*hiddenOutputs + i * SizeOf(Float)) * PeekF(*nn\HiddenOutputWeights + i * SizeOf(Float))
  Next
  PokeF(*finalOutput, Sigmoid(temp))
EndProcedure

; Step 4: Train the Neural Network
Procedure TrainNetwork(*nn.NeuralNetwork, *inputs.Float, *targetOutput.Float, learningRate.f)
  ; Forward pass
  Protected Dim hiddenOutputs.f(*nn\HiddenNodes)
  Protected finalOutput.f
  ForwardPass(*nn, *inputs, @hiddenOutputs(), @finalOutput)
  
  ; Calculate errors
  Protected outputError.f
  outputError = PeekF(*targetOutput) - finalOutput
  
  Protected Dim hiddenErrors.f(*nn\HiddenNodes)
  Protected i.i, j.i
  Protected delta.f
  For i = 0 To *nn\HiddenNodes - 1
    hiddenErrors(i) = outputError * finalOutput * (1 - finalOutput) * PeekF(*nn\HiddenOutputWeights + i * SizeOf(Float))
  Next
  
  ; Update weights
  ; Hidden to output
  For i = 0 To *nn\HiddenNodes - 1
    delta = learningRate * outputError * finalOutput * (1 - finalOutput) * PeekF(@hiddenOutputs(i))
    PokeF(*nn\HiddenOutputWeights + i * SizeOf(Float), PeekF(*nn\HiddenOutputWeights + i * SizeOf(Float)) + delta)
  Next
  
  ; Input to hidden
  For i = 0 To *nn\InputNodes - 1
    For j = 0 To *nn\HiddenNodes - 1
      delta = learningRate * hiddenErrors(j) * hiddenOutputs(j) * (1 - hiddenOutputs(j)) * PeekF(*inputs + i * SizeOf(Float))
      PokeF(*nn\InputHiddenWeights + (i * *nn\HiddenNodes + j) * SizeOf(Float), PeekF(*nn\InputHiddenWeights + (i * *nn\HiddenNodes + j) * SizeOf(Float)) + delta)
    Next
  Next
EndProcedure

; Step 5: Training Loop
Procedure Train(*nn.NeuralNetwork, epochs.i, learningRate.f)
  Protected i.i, j.i
  Protected Dim inputs.f(2)
  Protected targetOutput.f
  
  For i = 0 To epochs - 1
    For j = 0 To ArraySize(odata())
      inputs(0) = odata(j)\a / 100.0
      inputs(1) = odata(j)\b / 100.0
      
      targetOutput = odata(j)\result
      
      TrainNetwork(*nn, @inputs(), @targetOutput, learningRate)
    Next
  Next
EndProcedure

Define nn.NeuralNetwork
InitializeNetwork(@nn, 2, 10, 1) ; Increased number of hidden nodes to 10

; Step 6: Evaluate and Test
Procedure.f TestNetwork(*nn.NeuralNetwork, a.i, b.i, operator.s)
  Protected Dim inputs.f(2)
  Protected Dim hiddenOutputs.f(*nn\HiddenNodes)
  Protected finalOutput.f
  
  inputs(0) = a / 100.0
  inputs(1) = b / 100.0
  
  ForwardPass(*nn, @inputs(), @hiddenOutputs(), @finalOutput)
  
  Select operator
    Case "+", "-"
      ProcedureReturn finalOutput * 100.0
    Case "*"
      ProcedureReturn finalOutput * 10000.0
    Case "/"
      ProcedureReturn finalOutput * 100.0
  EndSelect
EndProcedure

; Train the network
Train(@nn, 50000, 0.1) ; Increased number of epochs to 50000

; Test the network with some examples
Debug "Testing the trained network:"
Debug "5 + 3 = " + StrF(TestNetwork(@nn, 5, 3, "+"), 2)
Debug "9 - 2 = " + StrF(TestNetwork(@nn, 9, 2, "-"), 2)
Debug "7 * 4 = " + StrF(TestNetwork(@nn, 7, 4, "*"), 2)
Debug "8 / 2 = " + StrF(TestNetwork(@nn, 8, 2, "/"), 2)

; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; CursorPosition = 207
; FirstLine = 167
; Folding = ---
; EnableAsm
; EnableThread
; EnableXP
; CPU = 1
; EnablePurifier
; EnableCompileCount = 14
; EnableBuildCount = 0
; EnableExeConstant