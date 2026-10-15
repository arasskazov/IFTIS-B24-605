#include <atomic>
#include <iostream>
#include <mutex>
#include <thread>
#include <vector>

int main() {
    constexpr int kThreads = 4;
    constexpr int kIters = 100000;
    std::atomic<int> a{0};
    int m = 0;
    std::mutex mtx;

    std::vector<std::thread> pool;
    for (int t = 0; t < kThreads; ++t) {
        pool.emplace_back([&] {
            for (int i = 0; i < kIters; ++i) {
                ++a;
                std::lock_guard<std::mutex> lk(mtx);
                ++m;
            }
        });
    }
    for (auto& th : pool) th.join();

    const int expected = kThreads * kIters;
    std::cout << "atomic=" << a << " mutex=" << m << " expected=" << expected << '\n';
    return (a == expected && m == expected) ? 0 : 1;
}
