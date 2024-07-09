; Step 1: Define Objects and Operations
Structure Operation
  a.i
  b.i
  operator.s
  result.i
EndStructure

Procedure Add(a.i, b.i)
  ProcedureReturn a + b
EndProcedure

Procedure Subtract(a.i, b.i)
  ProcedureReturn a - b
EndProcedure

; Step 2: Generate Training Data
Global Dim odata.Operation(1999)

Procedure GenerateData()
  Protected i.i
  For i = 0 To 999
    odata(i)\a = Random(99) + 1
    odata(i)\b = Random(99) + 1
    odata(i)\operator = "+"
    odata(i)\result = Add(odata(i)\a, odata(i)\b)
    
    odata(i + 1000)\a = Random(99) + 1
    odata(i + 1000)\b = Random(99) + 1
    odata(i + 1000)\operator = "-"
    odata(i + 1000)\result = Subtract(odata(i + 1000)\a, odata(i + 1000)\b)
  Next
EndProcedure

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
      inputs(0) = odata(j)\a
      inputs(1) = odata(j)\b
      
      If odata(j)\operator = "+"
        targetOutput = odata(j)\result / 200.0
      ElseIf odata(j)\operator = "-"
        targetOutput = odata(j)\result / 200.0
      EndIf
      
      TrainNetwork(*nn, @inputs(), @targetOutput, learningRate)
    Next
  Next
EndProcedure


; Step 6: Evaluate and Test
Procedure.f TestNetwork(*nn.NeuralNetwork, a.i, b.i, operator.s)
  Protected Dim inputs.f(2)
  Protected Dim hiddenOutputs.f(*nn\HiddenNodes)
  Protected finalOutput.f
  
  inputs(0) = a
  inputs(1) = b
  
  ForwardPass(*nn, @inputs(), @hiddenOutputs(), @finalOutput)
  
  ProcedureReturn finalOutput * 200.0
EndProcedure

;- Start

Debug "1. Generate Data"
GenerateData()

Debug "2. Initialise Network"

Define nn.NeuralNetwork
InitializeNetwork(@nn, 2, 5, 1)


; Step 7: Example Usage

Debug "3. Training"

Train(@nn, 10000, 0.1)
Debug "4. Training complete!"
Debug ""

Define a.i = 10
Define b.i = 20
Define operator.s = "+"
Define result.f = TestNetwork(@nn, a, b, operator)
Debug "The result of " + Str(a) + " " + operator + " " + Str(b) + " is " + StrF(result, 2)

a = 30
b = 15
operator = "-"
result = TestNetwork(@nn, a, b, operator)
Debug "The result of " + Str(a) + " " + operator + " " + Str(b) + " is " + StrF(result, 2)

; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; CursorPosition = 186
; FirstLine = 159
; Folding = --
; EnableAsm
; EnableThread
; EnableXP
; CPU = 1
; EnablePurifier
; EnableCompileCount = 4
; EnableBuildCount = 0
; EnableExeConstant