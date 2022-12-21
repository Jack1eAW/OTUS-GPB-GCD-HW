import Foundation

//MARK: - 1. Исследуйте код ниже и напишите, какие цифры должны вывестись в консоль, обьясните своими словами, почему именно такая последовательность по шагам.

// В главном потоке выводится 1. Потом запускается асинхронный блок. Асинхронно относительно главного потока он будет выполнен только, когда завершатся вызовы в очереди print("9"). После того, как был вызван асинхронный блок, выполнится print("2"). Далее вызывается блок, который выполняется синхронно внутри него вызывается print("3"). Затем в главной очереди вызывается синхронная функция из-за чего происходит дедлок.

func testQueue(){
    print("1")
    /// Асинхронный блок
    DispatchQueue.main.async {
        print("2")
        DispatchQueue.global(qos: .background).sync { /// #1
            print("3")
            /// Cинхронный блок
            DispatchQueue.main.sync { /// #2
                print("4")
                DispatchQueue.global(qos: .background).async { /// #3
                    print("5")
                }
                print("6")
            }
            print("7")
        }
        print("8")
    }
    print("9")
}

print("Output of task 1: ")
testQueue()
//MARK: - 2. Создайте свою серийную очередь и замените в примере ей DispatchQueue.main, создайте свою конкурентную очередь и заменить ей DispatchQueue.global(qos: .background). Какой будет результат? Всегда ли будет одинаковым? И почему?

// При замене DispatchQueue.main на serialQueue на выходе получаем результат 1 2 3 9
// Асинхронно к главному потоку ставим задачу в другую серийную очередь, тогда быстрее сработает тот вывод, поток для которого будет быстрее.

// При замене DispatchQueue.global(qos: .background) на concurrentQueue на выходе получаем результат  1 9 2 3
// Вывод всегда будет в одинаковой последовательноси, конкурентная очередь отличается только приоритетом.

let serialQueue = DispatchQueue(label: "serialQueue")
let concurrentQueue = DispatchQueue(label: "concurrentQueue", qos: .userInteractive, attributes: .concurrent)

func testQueue2(){
    print("1")
    serialQueue.async {
        print("2")
        DispatchQueue.global(qos: .background).sync {
//        concurrentQueue.sync {
            print("3")
            serialQueue.async {
                print("4")
                DispatchQueue.global(qos: .background).async {
//                concurrentQueue.async {
                    print("5")
                }
                print("6")
            }
            print("7")
        }
        print("8")
    }
    print("9")
}

print("Output of task 2: ")
testQueue2()
//MARK: - 3. Какой по номеру надо поменять sync/sync чтобы не возникало дедлока в обоих случаях
// Необходимо поменять местами 2 и 3
// DispatchQueue.main.sync { /// #2
// print("4")
// DispatchQueue.global(qos: .background).async { /// #3
//    print("5")
// }
// print("6")
// }

//MARK: - 4. Как можно сделать в примере, чтобы очередь превратилась из конкурентной в серийную, подправте пример не исправляя создания самой очереди
// С помощью semaphore. Он ограничивает количество потоков, которые обращаются к очереди.

let semaphore = DispatchSemaphore(value: 0)

func testQueue4(){
    print("1")
    DispatchQueue.main.async {
        print("2")
        semaphore.signal()
        DispatchQueue.global(qos: .background).sync {
            print("3")
            DispatchQueue.main.sync {
                print("4")
                DispatchQueue.global(qos: .background).async {
                    print("5")
                }
                print("6")
            }
            print("7")
        }
        print("8")
        semaphore.wait()
    }
    print("9")
}

print("Output of task 4: ")
testQueue4()

