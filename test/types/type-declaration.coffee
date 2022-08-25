{testCase} = require "../helper"

describe "[TS] type declaration", ->
  testCase """
    simple
    ---
    type x = Y
    ---
    type x = Y;
  """

  testCase """
    type parameters
    ---
    type Z<X, Y> = Array<X>
    ---
    type Z<X, Y> = Array<X>;
  """

  testCase """
    binary ops
    ---
    type A = B | C
    ---
    type A = B | C;
  """

  testCase """
    multiple ops
    ---
    type X = B | C | D
    type Y = B & C | D
    ---
    type X = B | C | D;
    type Y = B & C | D;
  """

  testCase """
    typeof
    ---
    const data = [1, 2, 3]
    type Data = typeof data
    ---
    const data = [1, 2, 3];
    type Data = typeof data;
  """

  testCase """
    conditional
    ---
    type Example1 = Dog extends Animal ? number : string
    ---
    type Example1 = Dog extends Animal ? number : string;
  """

  testCase """
    conditional infer
    ---
    type Example1 = Dog extends Animal<infer U> ? U : string
    ---
    type Example1 = Dog extends Animal<infer U> ? U : string;
  """

  testCase """
    parens
    ---
    type A = (X & Y) | (T & U)
    ---
    type A = (X & Y) | (T & U);
  """

  testCase """
    keyof
    ---
    type A = keyof B
    ---
    type A = keyof B;
  """

  testCase """
    indexed access
    ---
    type Age = Person["age"]
    ---
    type Age = Person["age"];
  """

  testCase """
    index signature
    ---
    type Arrayish = { [n: number]: unknown }
    ---
    type Arrayish = { [n: number]: unknown };
  """

  testCase """
    mapped type
    ---
    type OptionsFlags<Type> = {
      [Property in keyof Type]: boolean;
    };
    ---
    type OptionsFlags<Type> = {
      [Property in keyof Type]: boolean;
    };
  """

  testCase """
    mapped type
    ---
    type OptionsFlags<Type> = {
      [Property in keyof Type]: boolean;
    };
    ---
    type OptionsFlags<Type> = {
      [Property in keyof Type]: boolean;
    };
  """

  testCase """
    mapped type modifiers
    ---
    type OptionsFlags<Type> = {
      -readonly [Property in keyof Type]-?: boolean;
    };
    ---
    type OptionsFlags<Type> = {
      -readonly [Property in keyof Type]-?: boolean;
    };
  """

  testCase """
    remapped type
    ---
    type MappedTypeWithNewProperties<Type> = {
      [Properties in keyof Type as NewKeyType]: Type[Properties];
    };
    ---
    type MappedTypeWithNewProperties<Type> = {
      [Properties in keyof Type as NewKeyType]: Type[Properties];
    };
  """

  testCase """
    complicated
    ---
    type EventConfig<Events extends { kind: string }> = {
      [E in Events as E["kind"]]: (event: E) => void;
    };
    ---
    type EventConfig<Events extends { kind: string }> = {
      [E in Events as E["kind"]]: (event: E) => void;
    };
  """
