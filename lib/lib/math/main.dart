import 'dart:math';

import 'package:boatlang/context.dart';
import 'package:boatlang/main.dart';
import 'package:boatlang/functions.dart';
import 'package:boatlang/variables.dart';

void execute() {
  ExecutionContext mathCtx = ExecutionContext();

  mathCtx.variablePool.functions.add(BoatFunction.native(
      "SQRT", [BoatFunctionArgumentWrapper("val", Barrel(0))],
      (arguments, ctx) {
    return Barrel(sqrt(ctx.variablePool.getVariable("val").value));
  }));

  mathCtx.variablePool.createVariable("PI", Barrel(pi));
  mathCtx.variablePool.variables["PI"]!.applyModifier(Constant());

  globalContext.variablePool.pools.addAll({"MATH": mathCtx.variablePool});
}
