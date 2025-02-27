### 	1、单链表查询倒数第N个数据三种思路

思路1：先从头到尾遍历一遍链表记录元素总数，用总数–要查询位数，重新循环遍历表即可；

思路2：利用快慢指针，定义两个指针(fast、slow)，因为查询的是倒数第N个位置的数据，快指针先走N步；随后快慢指针一起走，只要快指针到尾了，慢指针所指的位置就是要查询的位置.

```js
bool SearchListTail(LinkList L,int sealoc)
{
	if(!L->next || sealoc < 0)
	{
		cerr << "Error.\n";
		return false;
	}
	LNode *fast = L->next;
	LNode *slow = L->next;
	for(int i = 0; i < sealoc; i++){
		if(fast)
			fast = fast->next;
		else
		{
			cerr << "sealoc error.\n";
			return false;
		}
	}
	while(fast){推广工具，迈凯轮，
  ；【‘/   靠谱O_I0-p=【；
		fast = fast->next;
		slow = slow->next;
	}
	cout << "The last " << sealoc << " item is " << slow->data << endl;
	return false;
}

```

思路3：利用递归，递归遍历链表，当递归触底时计数器记为0，递归返回时依次+1，当计数器和要查询的位置相同时停止递归，输出

```javascript
int CurSeaListTail(LinkList L,int sealoc)
{
	if(!L)	//链表触底时返回0 
		 return 0;
	int ans = CurSeaListTail(L->next,sealoc) + 1;	//计数触底时为0，依次返回+1 
	if(ans == sealoc)	//当计数和查找位置相同时 
	{
		cout << "The last " << sealoc << " item is " << L->data << endl;
		exit(EXIT_FAILURE);
	}
	return ans;
}

```



### 1、JS实现call、apply、bind

#### 1.1、实现call

```javascript
Function.prototype.myCall = function(thisArg, ...args) {
    const fn = Symbol('fn')        // 声明一个独有的Symbol属性, 防止fn覆盖已有属性
    thisArg = thisArg || window    // 若没有传入this, 默认绑定window对象
    thisArg[fn] = this              // this指向调用call的对象,即我们要改变this指向的函数
    const result = thisArg[fn](...args)  // 执行当前函数
    delete thisArg[fn]              // 删除我们声明的fn属性
    return result                  // 返回函数执行结果
}

//测试
foo.myCall(obj)
```

#### 1.2、实现apply

```javascript
Function.prototype.myApply = function(thisArg, args) {
    const fn = Symbol('fn')              // 声明一个独有的Symbol属性, 防止fn覆盖当前已有属性
    thisArg = thisArg || window          // 若没有传入this, 默认绑定window对象
    thisArg[fn] = this                   // this指向调用call的对象,即我们要改变this指向的函数
    const result = thisArg[fn](...args)  // 执行当前函数
    delete thisArg[fn]                   // 删除我们声明的fn属性
    return result                        // 返回函数执行结果
}

//测试
foo.myApply(obj, [])
```

#### 1.3、实现bind

```javascript
Function.prototype.myBind = function (thisArg, ...args) {
    var self = this
    // new 优先级
    var fbound = function () {
        self.apply(this instanceof self ? this : thisArg, args.concat(Array.prototype.slice.call(arguments)))
        console.log(arguments)
    }
    // 继承原型上的属性和方法
    fbound.prototype = Object.create(self.prototype);

    return fbound;
}

//test
const obj = { name: 'Nemo' }
function foo() {
    console.log(this.name)
    //  console.log(arguments)
}
foo.myBind(obj, 'a', 'b', 'c')("x")
```

#### 1.4、Find函数

```javascript
function find(arr,callback){
             for(let i=0;i<arr.length;i++){
                 let res = callback(arr[i],i)
                 if(res){
                     // 返回当前正在遍历的元素
                     return arr[i]
                 }
             }
             return undefined
         }
```

#### 1.5、reduce函数

```javascript
 function reduce(arr,callback,initValue){
             // 声明变量
             let result = initValue
             // 执行回调
             for(let i=0;i<arr.length;i++){
                 result = callback(result,arr[i])
             }
             return result
         }
```

#### 1.6、Filter函数

```javascript
export function filter(arr, callback) {
   // 定义空数组接收 回调返回为true的 元素
   let result = [];
   for (let i = 0; i < arr.length; i++) {
     let res = callback(arr[i], i);
     // 如果回调结果为真 就压入结果数组中
     if (res) {
       result.push(arr[i]);
     }
   }
   return result;
 }
```

### 2、JS实现 sleep/delay

```javascript
const sleep = (seconds) => new Promise(resolve => setTimeout(resolve, seconds))

function delay (func, seconds, ...args) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      Promise.resolve(func(...args)).then(resolve)
    }, seconds)
  })
}
```

### 3、js实现 Promise.all

```javascript
function pAll (_promises) {
  return new Promise((resolve, reject) => {
    // Iterable => Array
    const promises = Array.from(_promises)
    // 结果用一个数组维护
    const r = []
    const len = promises.length
    let count = 0
    for (let i = 0; i < len; i++) {
      // Promise.resolve 确保把所有数据都转化为 Promise
      Promise.resolve(promises[i]).then(o => { 
        // promise是异步的，保持数组一一对应
        r[i] = o;

        // 如果数组中所有 promise 都完成，则返回结果是数组
        if (++count === len) {
          resolve(r)
        }
        // 当发生异常时，直接 reject
      }).catch(e => reject(e))
    }
  })
}
```

### 4、去除字符串首尾空白字符

```javascript
const trim = str => str.trim || str.replace(/^\s+|\s+$/g, '')
```

### 5、函数节流throtle

让一个函数无法在短时间内连续调用，只有当上一次函数执行后，过了规定的时间间隔，才能进行下一次该函数的调用。或者说你在操作的时候不会马上执行该函数，而是等你不操作的时候才会执行。

```javascript
function throttle (f, wait) {
  let timer
  return (...args) => {
    if (timer) { return }
    timer = setTimeout(() => {
      f(...args)
      timer = null
    }, wait)
  }
}
```

### 6、函数防抖debounce

在事件触发后的规定时间段内，若事件没有再次触发，则对目标函数进行调用。

```javascript
function debounce (f, wait) {
  let timer
  return (...args) => {
    clearTimeout(timer)
    timer = setTimeout(() => {
      f(...args)
    }, wait)
  }
}
```

### 7、深拷贝

浅拷贝是创建一个新对象，这个对象有着原始对象属性值的拷贝。如果属性是基本类型，拷贝的就是基本类型的值，如果属性是引用类型，拷贝的是内存地址 。如果不进行深拷贝，其中一个对象改变了对象的值，就会影响到另一个对象的值。
深拷贝是将一个对象从内存中完整的拷贝一份出来,从堆内存中开辟一个新的区域存放新对象属性中,修改新对象并且不会影响原对象。

1、JSON.parse(JSON.stringify(obj))

```javascript
let a = {a:1,b:2}
let b = JSON.parse(JSON.stringify(a))
a.a = 11
console.log(a)//{a:1,b:2}
console.log(b)//{a:11,b:2}
缺陷：取不到值为 undefined 的 key；如果对象里有函数，函数无法被拷贝下来；无法拷贝copyObj对象原型链上的属性和方法；对象转变为 date 字符串。
```

2、使用递归函数实现深拷贝

```javascript
function deepClone(source) {
  if (typeof source !== 'object' || source == null) {
    return source;
  }
  const target = Array.isArray(source) ? [] : {};
  for (const key in source) {
    if (Object.prototype.hasOwnProperty.call(source, key)) {
      if (typeof source[key] === 'object' && source[key] !== null) {
        target[key] = deepClone(source[key]);
      } else {
        target[key] = source[key];
      }
    }
  }
  return target;
}

// 解决循环引用和symblo类型
function cloneDeep(source, hash = new WeakMap()) {
  if (typeof source !== 'object' || source === null) {
    return source;
  }
  if (hash.has(source)) {
    return hash.get(source);
  }
  const target = Array.isArray(source) ? [] : {};
  Reflect.ownKeys(source).forEach(key => {
    const val = source[key];
    if (typeof val === 'object' && val != null) {
      target[key] = cloneDeep(val, hash);
    } else {
      target[key] = val;
    }
  })
  return target;
}
```

3、兼容多种数据类型

```javascript
const deepClone = (source, cache) => {
  if(!cache){
    cache = new Map() 
  }
  if(source instanceof Object) { // 不考虑跨 iframe
    if(cache.get(source)) { return cache.get(source) }
    let result 
    if(source instanceof Function) {
      if(source.prototype) { // 有 prototype 就是普通函数
        result = function(){ return source.apply(this, arguments) }
      } else {
        result = (...args) => { return source.call(undefined, ...args) }
      }
    } else if(source instanceof Array) {
      result = []
    } else if(source instanceof Date) {
      result = new Date(source - 0)
    } else if(source instanceof RegExp) {
      result = new RegExp(source.source, source.flags)
    } else {
      result = {}
    }
    cache.set(source, result)
    for(let key in source) { 
      if(source.hasOwnProperty(key)){
        result[key] = deepClone(source[key], cache) 
      }
    }
    return result
  } else {
    return source
  }
}
```

4、jquery.extend()方法

```javascript
可以使用$.extend进行深拷贝
$.extend(deepCopy, target, object1, [objectN]) //第一个参数为true,就是深拷贝


let a = {
    a: 1,
    b: { d:8},
    c: [1, 2, 3]
};
let b = $.extend(true, {}, a);
console.log(a.b.d === b.b.d); // false
```

### 8、实现深比较的函数 deepEqual

```javascript
const obj1 = {
    a:100,
    b:{
        x:100,
        y:200
    }
}
const obj2 = {5 [ [56
    a:100,
    b:{
        x:100,
        y:200
    }
}
// 深度比较
function deepEqual(obj1 , obj2){
    if(!isObject(obj1) || !isObject(obj2)){
        return obj1 === obj2
    }
    if(obj1 === obj2){
        return true
        //特殊情况,直接判断相等
    }
    let arr1 = Object.keys(obj1)
    let arr2 = Object.keys(obj2)
    if(arr1.length !== arr2.length){
        return false
    }
    for(let key in obj1){
        if(!deepEqual(obj1[key] , obj2[key])){
            return false
        }
    }
    return true
}
function isObject(obj){
    return typeof obj === "object" && obj !== null
}
 console.log( deepEqual(obj1 , obj2) )
```

### 9、实现深复制的函数deepClone

```javascript
var obj = {
    "a" : 12 ,
    "b" : [1,2,3,4] ,
    "c" : {"name" : "周杰伦" ,"id" : "232" , "sex" : []}
}
// 深度复制
function deepClone(obj , target){
    let tar = target || {}
    //target为空或者没有传第二个参数的时候
    let tostring = Object.prototype.toString
    for(let key in obj){
        if(obj.hasOwnProperty(key)){
            if(typeof obj[key] === 'object'){
                tar[key] = tostring.call(obj[key]) === "[object Object]"?{}:[]
                deepClone(obj[key] , tar[key])
            }else{
                tar[key] = obj[key]
            }
        }
    }
    return tar
}
console.log( deepClone(obj) )
```

### 10、实现chunk函数，数组进行分组

```javascript
function chunk (list, size) {
  const l = []
  for (let i = 0; i < list.length; i++ ) {
    const index = Math.floor(i / size)
    l[index] ??= [];
    l[index].push(list[i])
  }
  return l
}
```

### 11、统计数组中最大的数/第二大的数

```javascript
1、求最大值
function max (list) {
  if (!list.length) { return 0 }
  return list.reduce((x, y) => x > y ? x : y)
}

2、求最大的两个值
function maxTwo (list) {
  let max = -Infinity, secondMax = -Infinity
  for (const x of list) {
    if (x > max) {
      secondMax = max
      max = x
    } else if (x > secondMax) {
      secondMax = x
    }
  }
  return [max, secondMax]
}
```

### 12、数组与树互转

```javascript
const arr = [
    {id:1, parentId: null, name: 'a'},
    {id:2, parentId: null, name: 'b'},
    {id:3, parentId: 1, name: 'c'},
    {id:4, parentId: 2, name: 'd'},
    {id:5, parentId: 1, name: 'e'},
    {id:6, parentId: 3, name: 'f'},
    {id:7, parentId: 4, name: 'g'},
    {id:8, parentId: 7, name: 'h'},
]
 ## 数组转树
// 利用map存储数组项，空间换时间
function array2Tree(arr){
    if(!Array.isArray(arr) || !arr.length) return;
    let map = {};
    arr.forEach(item => map[item.id] = item);

    let roots = [];
    arr.forEach(item => {
        const parent = map[item.parentId];
        if(parent){
            (parent.children || (parent.children=[])).push(item);
        }
        else{
            roots.push(item);
        }
    })

    return roots;
}

// 利用递归
// 需要插入父节点id，pid为null或''，就是找root节点，然后root节点再去找自己的子节点
function array2Tree(data, pid){
    let res = [];
    data.forEach(item => {
        if(item.parentId === pid){
            let itemChildren = array2Tree(data,item.id);
            if(itemChildren.length) item.children = itemChildren;
            res.push(item);
        }
    });
    return res;
}

## 树转数组
// 深度优先遍历
function dfs(root,fVisit){
    let stack = Array.isArray(root) ? [...root] : [root];
    while(stack.length){
        let node = stack.pop();
        fVisit && fVisit(node);
        let children = node.children;
        if(children && children.length){
            for(let i=children.length-1;i>=0;i--) stack.push(children[i]);
        }
    }
}

//  广度优先遍历
function bfs(root,fVisit){
    let queue = Array.isArray(root) ? [...root] : [root];
    while(queue.length){
        let node = queue.shift();
        fVisit && fVisit(node);
        let children = node.children;
        if(children && children.length){
            for(let i=0;i<children.length;i++) queue.push(children[i]);
        }
    }
}
```

### 13、树转数组

```javascript
const tree = [
  {
    id: 1,
    title: '研发部',
    pid: null,
    children: [
      {
        id: 5,
        title: '前端研发部',
        pid: 1
      },
      { id: 6, title: '后端研发部', pid: 1 },
      { id: 7, title: '算法研发部', pid: 1 }
    ]
  },
  {
    id: 2,
    title: '研发部',
    pid: null,
    children: [
      { id: 5, title: '前端研发部', pid: 2 },
      { id: 6, title: '后端研发部', pid: 2 },
      { id: 7, title: '算法研发部', pid: 2 }
    ]
  },
  {
    id: 3,
    title: '市场部',
    pid: null
  },
  {
    id: 4,
    title: '销售部',
    pid: null
  }
]
function treeToArray(tree) {
  const obj = []
  tree.forEach((item) => {
    if (item.children) {
      obj.push( item, ...item.children )
      // ES6新增的删除对象的属性 Reflect.deleteProperty(对象，属性名)
      Reflect.deleteProperty(item,'children')
    } else {
      obj.push(item)
    }
  })
  return obj
}
console.log(treeToArray(tree))
```



### 14、统计字符串中出现次数最多的字符

```javascript
function getFrequentChar (str) {
  const dict = {}
  for (const char of str) {
    dict[char] = (dict[char] || 0) + 1
  }
  const maxBy = (list, keyBy) => list.reduce((x, y) => keyBy(x) > keyBy(y) ? x : y)
  return maxBy(Object.entries(dict), x => x[1])
}

// 以下方案一边进行计数统计一遍进行大小比较，只需要1次O(n)的算法复杂度
function getFrequentChar2 (str) {
  const dict = {}
  let maxChar = ['', 0]
  for (const char of str) {
    dict[char] = (dict[char] || 0) + 1
    if (dict[char] > maxChar[1]) {
      maxChar = [char, dict[char]]
    }
  }
  return maxChar
}
```

### 15、实现new()

```javascript
function myNew(Func, ...args) {
  const instance = {};
  if (Func.prototype) {
    Object.setPrototypeOf(instance, Func.prototype)
  }
  const res = Func.apply(instance, args)
  if (typeof res === "function" || (typeof res === "object" && res !== null)) {
    return res
  }
  return instance
}

// 测试
function Person(name) {
  this.name = name
}
Person.prototype.sayName = function() {
  console.log(`My name is ${this.name}`)
}
const me = myNew(Person, 'Jack')
me.sayName()
console.log(me)
```

### 16、事件总线 | 发布订阅模式

```javascript
class EventEmitter {
  constructor() {
    this.cache = {}
  }

  on(name, fn) {
    if (this.cache[name]) {
      this.cache[name].push(fn)
    } else {
      this.cache[name] = [fn]
    }
  }

  off(name, fn) {
    const tasks = this.cache[name]
    if (tasks) {
      const index = tasks.findIndex((f) => f === fn || f.callback === fn)
      if (index >= 0) {
        tasks.splice(index, 1)
      }
    }
  }

  emit(name) {
    if (this.cache[name]) {
      // 创建副本，如果回调函数内继续注册相同事件，会造成死循环
      const tasks = this.cache[name].slice()
      for (let fn of tasks) {
        fn();
      }
    }
  }

  emit(name, once = false) {
    if (this.cache[name]) {
      // 创建副本，如果回调函数内继续注册相同事件，则会造成死循环导致内存泄漏崩溃等问题
      const tasks = this.cache[name].slice()
      for (let fn of tasks) {
        fn();
      }
      if (once) {
        delete this.cache[name]
      }
    }
  }
}

// 测试
const eventBus = new EventEmitter()
const task1 = () => { console.log('task1'); }
const task2 = () => { console.log('task2'); }
eventBus.on('task', task1)
eventBus.on('task', task2)

setTimeout(() => {
  eventBus.emit('task')
}, 1000)
```

### 17、柯里化函数

只传递给函数一部分参数来调用它，让它返回一个函数去处理剩下的参数

```javascript
function curry(func) {
  return function curried(...args) {
    // 关键知识点：function.length 用来获取函数的形参个数
    // 补充：arguments.length 获取的是实参个数
    if (args.length >= func.length) {
      return func.apply(this, args)
    }
    return function (...args2) {
      return curried.apply(this, args.concat(args2))
    }
  }
}
// 测试
function sum (a, b, c) {
  return a + b + c
}
const curriedSum = curry(sum)
console.log(curriedSum(1, 2, 3))
console.log(curriedSum(1)(2,3))
console.log(curriedSum(1)(2)(3))
```

### 18、异步并发数限制

```javascript
/**
 * 关键点
 * 1. new promise 一经创建，立即执行
 * 2. 使用 Promise.resolve().then 可以把任务加到微任务队列，防止立即执行迭代方法
 * 3. 微任务处理过程中，产生的新的微任务，会在同一事件循环内，追加到微任务队列里
 * 4. 使用 race 在某个任务完成时，继续添加任务，保持任务按照最大并发数进行执行
 * 5. 任务完成后，需要从 doingTasks 队列中移出掉
 */
function limit(count, array, iterateFunc) {
  const tasks = []
  const doingTasks = []
  let i = 0
  const enqueue = () => {
    if (i === array.length) {
      return Promise.resolve()
    }
    const task = Promise.resolve().then(() => iterateFunc(array[i++]))
    tasks.push(task)
    const doing = task.then(() => doingTasks.splice(doingTasks.indexOf(doing), 1))
    doingTasks.push(doing)
    const res = doingTasks.length >= count ? Promise.race(doingTasks) : Promise.resolve()
    return res.then(enqueue)
  };
  return enqueue().then(() => Promise.all(tasks))
}

// test
const timeout = i => new Promise(resolve => setTimeout(() => resolve(i), i))
limit(2, [1000, 1000, 1000, 1000], timeout).then((res) => {
  console.log(res)
})
```

### 19、实现一个异步加法

```javascript
function asyncAdd(a, b, callback) {
  setTimeout(function () {
    callback(null, a + b);
  }, 500);
}

// 解决方案
// 1. promisify
const promiseAdd = (a, b) => new Promise((resolve, reject) => {
  asyncAdd(a, b, (err, res) => {
    if (err) {
      reject(err)
    } else {
      resolve(res)
    }
  })
})

// 2. 异步串行处理
async function serialSum(...args) {
  return args.reduce((task, now) => task.then(res => promiseAdd(res, now)), Promise.resolve(0))
}

// 3. 异步并行处理
async function parallelSum(...args) {
  if (args.length === 1) return args[0]
  const tasks = []
  for (let i = 0; i < args.length; i += 2) {
    tasks.push(promiseAdd(args[i], args[i + 1] || 0))
  }
  const results = await Promise.all(tasks)
  return parallelSum(...results)
}

// 测试
(async () => {
  console.log('Running...');
  const res1 = await serialSum(1, 2, 3, 4, 5, 8, 9, 10, 11, 12)
  console.log(res1)
  const res2 = await parallelSum(1, 2, 3, 4, 5, 8, 9, 10, 11, 12)
  console.log(res2)
  console.log('Done');
})()
```

### 19、js实现 vue 双向绑定

### 20、promise

#### 1、promise

```javascript
// 建议阅读 [Promises/A+ 标准](https://promisesaplus.com/)
class MyPromise {
  constructor(func) {
    this.status = 'pending'
    this.value = null
    this.resolvedTasks = []
    this.rejectedTasks = []
    this._resolve = this._resolve.bind(this)
    this._reject = this._reject.bind(this)
    try {
      func(this._resolve, this._reject)
    } catch (error) {
      this._reject(error)
    }
  }

  _resolve(value) {
    setTimeout(() => {
      this.status = 'fulfilled'
      this.value = value
      this.resolvedTasks.forEach(t => t(value))
    })
  }

  _reject(reason) {
    setTimeout(() => {
      this.status = 'reject'
      this.value = reason
      this.rejectedTasks.forEach(t => t(reason))
    })
  }

  then(onFulfilled, onRejected) {
    return new MyPromise((resolve, reject) => {
      this.resolvedTasks.push((value) => {
        try {
          const res = onFulfilled(value)
          if (res instanceof MyPromise) {
            res.then(resolve, reject)
          } else {
            resolve(res)
          }
        } catch (error) {
          reject(error)
        }
      })
      this.rejectedTasks.push((value) => {
        try {
          const res = onRejected(value)
          if (res instanceof MyPromise) {
            res.then(resolve, reject)
          } else {
            reject(res)
          }
        } catch (error) {
          reject(error)
        }
      })
    })
  }

  catch(onRejected) {
    return this.then(null, onRejected);
  }
}

// 测试
new MyPromise((resolve) => {
  setTimeout(() => {
    resolve(1);
  }, 500);
}).then((res) => {
    console.log(res);
    return new MyPromise((resolve) => {
      setTimeout(() => {
        resolve(2);
      }, 500);
    });
  }).then((res) => {
    console.log(res);
    throw new Error('a error')
  }).catch((err) => {
    console.log('==>', err);
  })
```

#### 2、Promise.race

```javascript
// 由数组中最先改变状态的promise返回决定
         Promise.race = function(promises){
         return new Promise((resolve,reject)=>{
             for(let i = 0;i <promises.length;i++){
                 promises[i].then(v=>{
                     // 修改返回对象的状态
                     resolve(v);
                 },r=>{
                     reject(r);
                 })
             }
         })
     }
```

#### 3、Promise.all

```javascript
// 适用于处理多个异步任务，且所有的异步任务都得到结果时的情况
         Promise.all = function(promises){
         return new Promise((resolve, reject)=>{
             let count = 0
             const values = []
             for(let i = 0; i < promises.length; i++){
                 Promise.resolve(promise[i]).then(value => {
                     count++
                     values[i] = value
                     if(count === promises.length){
                         resolve(values)
                     }
                 }, reason => { 
                     reject(reason) 
                 })
             }
         })
     }
```

### 21、数组扁平化

```javascript
// 方案 1
function recursionFlat(ary = []) {
  const res = []
  ary.forEach(item => {
    if (Array.isArray(item)) {
      res.push(...recursionFlat(item))
    } else {
      res.push(item)
    }
  })
  return res
}
// 方案 2
function reduceFlat(ary = []) {
  return ary.reduce((res, item) => res.concat(Array.isArray(item) ? reduceFlat(item) : item), [])
}

// 测试
const source = [1, 2, [3, 4, [5, 6]], '7']
console.log(recursionFlat(source))
console.log(reduceFlat(source))
```

### 22、对象扁平化处理

```javascript
function objectFlat(obj = {}) {
  const res = {}
  function flat(item, preKey = '') {
    Object.entries(item).forEach(([key, val]) => {
      const newKey = preKey ? `${preKey}.${key}` : key
      if (val && typeof val === 'object') {
        flat(val, newKey)
      } else {
        res[newKey] = val
      }
    })
  }
  flat(obj)
  return res
}
// 测试
const source = { a: { b: { c: 1, d: 2 }, e: 3 }, f: { g: 2 } }
console.log(objectFlat(source));
```

### 23、图片懒加载

```javascript
// <img src="default.png" data-src="https://xxxx/real.png">
function isVisible(el) {
  const position = el.getBoundingClientRect()
  const windowHeight = document.documentElement.clientHeight
  // 顶部边缘可见
  const topVisible = position.top > 0 && position.top < windowHeight;
  // 底部边缘可见
  const bottomVisible = position.bottom < windowHeight && position.bottom > 0;
  return topVisible || bottomVisible;
}

function imageLazyLoad() {
  const images = document.querySelectorAll('img')
  for (let img of images) {
    const realSrc = img.dataset.src
    if (!realSrc) continue
    if (isVisible(img)) {
      img.src = realSrc
      img.dataset.src = ''
    }
  }
}

// 测试
window.addEventListener('load', imageLazyLoad)
window.addEventListener('scroll', imageLazyLoad)
// or
window.addEventListener('scroll', throttle(imageLazyLoad, 1000))
```

### 24、字符串转驼峰

```javascript
const camelCase = (string) => {
   const camelCaseRegex = /[-_\s]+(.)?/g
   return string.replace(camelCaseRegex, (match, char) => {
     return char ? char.toUpperCase() : ''
   })
 }
```

### 25、随机生成颜色

```javascript
 function rgb(){//rgb颜色随机
                var r = Math.floor(Math.random()*256);
                var g = Math.floor(Math.random()*256);
                var b = Math.floor(Math.random()*256);
                var rgb = '('+r+','+g+','+b+')';
                return rgb;
            }
 function color16(){//十六进制颜色随机
                var r = Math.floor(Math.random()*256);
                var g = Math.floor(Math.random()*256);
                var b = Math.floor(Math.random()*256);
                var color = '#'+r.toString(16)+g.toString(16)+b.toString(16);
                return color;
            }
```

### 26、每隔3s打印hello 打印四次

```javascript
function repeact(str,time,print){
             return function(s){
                 for(let i=0;i<time;i++){
                     setTimeout(()=>{
                         str(s)
                     },print*(i+1))
                 }
             }
         }
         const repeatFunc = repeact(console.log,4,3000)
         repeatFunc('hello')
```

### 27、A是否为B 的子串 的判断函数（不借用原有api）

```js
/**
 * 通过for循环判断A是否为B的子串
 * @param {String} comp - 被对比的字符串(B)
 * @returns {Boolean}
 */
String.prototype.isSubStrOf = function(comp) {
  const str = this.valueOf();

  if (typeof comp !== 'string') {
    if (!(comp instanceof String)) return false;
    comp = comp.valueOf();
  }
  if (str === comp || str === '') return true;

  const compLen = comp.length;
  const len = str.length;
  let index = 0;

  for (let i = 0; i < compLen; i++) {
    if (comp[i] === str[index]) {
      if (index === len - 1) return true;
      index++;
    } else {
      index > 0 ? index-- : (index = 0);
    }
  }

  return false;
}
```

### 28、js判断一个字符串是否是回文字符串

```javascript
function palindRome(str){
    var len = str.length;
    var str1 = "";
    for(var i=len-1; i>=0;i--){
        str1+=str[i];
    }
    console.log(str1 == str)
}
palindRome("abcba");//true
palindRome("abcbac");//false


function palindRome(str){
    var len = str.length;
    for(var i=0; i<len;i++){if(str.charAt(i)!=str.charAt(len-1-i)){
            console.log("不是")
        }else{
            console.log("是")
        }
    } 
}
palindRome("abcba");//是
palindRome("abcbac");//不是
```

### 29、算法：最长回文子串（js）

```javascript
思路：两边扩散，若扩散的左右两边相等则仍然是回文子串，每得到一个更大长度的回文子串就赋给res。
var longestPalindrome = function(s) {
    let res = ''
    for (let i = 0; i < s.length; i ++) {
        let left = i - 1, right = i + 1 // s为奇数长度
        while (left >= 0 && right < s.length && s[left] === s[right]) {
            left --, right ++
        }
        if (res.length < right - left - 1) {
            res = s.substring(left + 1, right)
        }
 
        left = i, right = i + 1 // s为偶数长度
        while (left >= 0 && right < s.length && s[left] === s[right]) {
            left --, right ++
        }
        if (res.length < right - left - 1) {
            res = s.substring(left + 1, right)
        }
    }
    return res
};
```

### 30、二叉树后序遍历

```javascript
// 递归算法
var postorderTraversal = function(root , array = []){
    if(root){
        postorderTraversal(root.left , array);
        postorderTraversal(root.right , array);
        array.push(root.val);
    }
    return array;
}

// 非递归算法 初始化一个栈、结果数组和记录上次访问节点的变量，当栈不为空或根节点不为空时，重复下面的步骤：
1、将左孩子入栈 → 直至左孩子为空
2、栈顶节点的右节点为空或被访问过 → 节点出栈，存入结果数组，标记为已访问，继续出栈查找。
3、栈顶节点的右节点不为空且未被访问 ，以右孩子为目标节点，执行1 、2 、3
var postorderTraversal = function (root) {
  const result = [];
  const stack = [];
  var last = null; //标记上一个访问的节点
  let current = root;
  while (stack.length > 0 || current) {
    while (current) {
      stack.push(current);
      current = current.left;
    }
    current = stack[stack.length - 1];
    if (!current.right || current.right == last) {
      current = stack.pop();
      result.push(current.val);
      last = current;
      current = null;
    } else {
      current = current.right;
    }
  }
  return result;
}
```

https://blog.csdn.net/qq_43080484/article/details/125448550

### 31、compose的实现

compose的作用就是组合函数，将函数串联起来执行，前一个函数的输出值是后一个函数的输入值

```javascript
function fn1(x){
    return x + 1
}
function fn2(x){
    return x * 10
}
function fn3(x){
    return x - 1
}
let x = 10
let result = fn3(fn2(fn1(x))) // 109

// 递归 可以看出其实就是将传入compose的函数逐个执行一次，并且参数也要逐层传递下去,最后返回一个函数
function compose(...fns) {
    let len = fns.length
    let res = null
    return function fn(...arg) {
        res = fns[len - 1].apply(null, arg) // 每次函数运行的结果
        if(len > 1) {
            len --
            return fn.call(null, res) // 将结果递归传给下一个函数
        } else {
            return res //返回结果
        }
    }
}
```

### 32、get每周中任意一天是几号

```javascript
	/**
	 * @param {timeStamp/string} date 非必传。例如：传入'2021-01-01'，则查找2021年1月份，默认查找当前月份。
	 * @param {number} expectDay 非必传。例如：传入3，则查找当前月份中每周三是几号，其中(0代表周日, 1-6分别代表周一至周六)，默认0。
	 */
	function weeks(expectDay, date) {
		//fix arugments
		if (typeof date == "string") {
			date = new Date(date);
		} else if (typeof date == "number") {
			date = new Date(date);
		} else if (date == null) {
			date = new Date();
		} else if (!(date instanceof Date)) {
			throw "unexpect type of date";
		}
 
		expectDay = expectDay % 7;
 
		if (!expectDay) {
			expectDay = 0;
		}
 
		// find first expect day
		date.setDate(1);
		if (date.getDay() != expectDay) {
			date.setDate((expectDay + 7 - date.getDay()) % 7 + 1);
		}
 
		// record current month
		var month = date.getMonth();
		var arr = [];
		do {
			// push expect days
			arr.push(date.toISOString().substring(0, 10));
			date.setDate(date.getDate() + 7);
			// keep month
		} while (date.getMonth() == month);
 
		return arr;
	}
	console.log('依次是', weeks());
```

### 33、字符串压缩

```javascript
s = input()
i = 0
count = 0
res = ''
while i < len(s):
    count = 0
    while i+1 < len(s) and s[i] == s[i+1]:
        count += 1
        i += 1
    if count != 0:
        res += str(count)
    res += s[i]
    i += 1
print(res)
```

### 34、JS判断字符串中是否含有重复字符

```js
// while
function check( str ) {
    while( str.length ) { 
        // 取字符串的第一个字符，在剩余的字符中查找，如果找到则说明有重复
        if( str.slice(1).indexof( str.charat( 0 ) ) > -1 ) {
            return true; 
        }
        // 如果没找到，把字符串去掉第一个字符，继续查找
        str = str.slice(1);
    }
    return false;
}
check( 'abcdefg' ); // return false

// 还可以通过正则表达式来实现，就一行代码：
function check( str ) {
    return /(.).*?\1/.test( str );
}
```

### 35、十进制转换为二进制（用js实现）

```javascript
1. js 中二进制和十进制的相互转换：
var num = 10;

num.toString(2);       // 十进制转二进制
num.toString(8);       // 十进制转八进制
num.toString(10);      // 十进制转十进制
num.toString(16);      // 十进制转十六进制

parseInt(num, 2);      // 二进制转十进制；num 被看做是二进制的数
parseInt(num, 8);      // 八进制转十进制；num 被看做是八进制的数
parseInt(num, 16);     // 十六进制转十进制；num 被看做是十六进制的数

parseInt(num, 2).toString(8);     // 二进制转八进制；也可以看做是二进制先转成十进制，再转成八进制
parseInt(num, 2).toString(16);    // 二进制转十六进制；也可以看做是二进制先转成十进制，再转成十六进制

2. 自定义实现 十进制转二进制
let numberToBinary = function(num) {
    var result = [];

    if (num < 0) {
        return num;
    }

    // 使用 do while 解决 num 等于 0 的情况
    do {
        var temp = num % 2;
        temp == 0 ? result.push('0') : result.push('1');
        num = Math.floor(num / 2);
    } while(num != 0);

    // 反转数组
    result.reverse();

    return result.join('');
}
```
