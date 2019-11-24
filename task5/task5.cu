#include <iostream>

#define N (2048*2048)
#define THREADS_PER_BLOCK 512

// #define N (8*8)
// #define THREADS_PER_BLOCK 8

__global__ void add(int *a, int *b, int *c) {
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    c[index] = a[index] + b[index];
}

void random_ints(int *a, int size) {
    for (int i = 0; i < size; i++) {
        a[i] = rand();
    }
}

int main(void) {
    srand(100);
    int *a, *b, *c; // host копии a, b, c
    int *dev_a, *dev_b, *dev_c; // device копии of a, b, c
    int size = N * sizeof(int);
    //выделяем память на device для of a, b, c
    cudaMalloc((void**)&dev_a, size);
    cudaMalloc((void**)&dev_b, size);
    cudaMalloc((void**)&dev_c, size);
    a = (int*)malloc(size);
    b = (int*)malloc(size);
    c = (int*)malloc(size);
    random_ints(a, N);
    random_ints(b, N);

    //копируем ввод на device
    cudaMemcpy(dev_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, size, cudaMemcpyHostToDevice);
    //запускаем на выполнение add() kernel с блоками и тредами
    add<<<N/THREADS_PER_BLOCK, THREADS_PER_BLOCK>>>(dev_a, dev_b, dev_c);
    // копируем результат работы device на host ( копия c )
    cudaMemcpy(c, dev_c, size, cudaMemcpyDeviceToHost);

    for (int i = 0; i < N; i++) {
        std::cout << c[i] << " ";
    }
    std::cout << "\n";

    free(a); free(b); free(c);
    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);
    return 0;
}