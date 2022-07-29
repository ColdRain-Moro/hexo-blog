---
title: 用ASM写一个HelloWorld
date: 2021-10-11 11:46:08
author: 寒雨
hide: false
summary: 尝试了一下asm库，用它生成了一个helloworld的代码
categories: 笔记
tags:
  - 外部库
  - ASM
  - Java
---

# 用ASM写一个HelloWorld

今天上计算机应用能力课的时候太无聊，简单的研究了一下ASM，用ASM生成了一个含有HelloWorld的类
不得不说，ASM是真的黑魔法

## 代码

```kotlin
public class ASMTest {

    public static void main(String[] args) throws NoSuchMethodException, InvocationTargetException, IllegalAccessException {
        byte[] bytes = generate();
        MyClassLoader cl = new MyClassLoader();
        Class<?> clazz = cl.defineClass("team.redrock.coldrain.asmtest.HelloWorldASM", bytes);
        Method m = clazz.getMethod("main", String[].class);
        m.invoke(null, new Object[]{new String[]{}});
    }

    static byte[] generate() {
        ClassWriter cw = new ClassWriter(0);
        cw.visit(Opcodes.V1_8, Opcodes.ACC_PUBLIC, "team/redrock/coldrain/asmtest/HelloWorldASM", null, "java/lang/Object", null);
        MethodVisitor mv = cw.visitMethod(Opcodes.ACC_PUBLIC + Opcodes.ACC_STATIC, "main", "([Ljava/lang/String;)V", null, null);
        mv.visitFieldInsn(Opcodes.GETSTATIC, "java/lang/System", "out", "Ljava/io/PrintStream;");
        mv.visitLdcInsn("Hello ASM!");
        mv.visitMethodInsn(Opcodes.INVOKEVIRTUAL, "java/io/PrintStream", "println", "(Ljava/lang/String;)V", false);
        mv.visitInsn(Opcodes.RETURN);
        mv.visitMaxs(2, 1);
        mv.visitEnd();
        cw.visitEnd();
        return cw.toByteArray();
    }

    static class MyClassLoader extends ClassLoader {
        public Class<?> defineClass(String name, byte[] b) {
            return super.defineClass(name, b, 0, b.length);
        }
    }
}
```