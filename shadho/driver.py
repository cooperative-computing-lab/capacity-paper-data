from shadho import Shadho, rand
import time

C = rand.log2_uniform(-5, 15)
gamma = rand.log10_uniform(-3, 3)
coef0 = rand.uniform(-1000, 1000)
degree = rand.randint(0, 15)

spec = {
    'exclusive': True,
    'linear': {
        'kernel': 'linear',
        'C': C,
    },
    'rbf': {
        'kernel': 'rbf',
        'C': C,
        'gamma': gamma,
    },
    'sigmoid': {
        'kernel': 'sigmoid',
        'C': C,
        'gamma': gamma,
        'coef0': coef0,
    },
    'poly': {
        'kernel': 'poly',
        'C': C,
        'gamma': gamma,
        'coef0': coef0,
        'degree': degree,
    },
}

files = ['svm.py',
         'svm.sh',
         'mnist.npz']


if __name__ == "__main__":
    #start = time.time()
    opt = Shadho('./svm.sh', spec, use_priority=True, use_complexity=True, timeout=3600, max_tasks=150, max_resubmissions=3)
    
    for i in files:
        opt.add_input_file(i)
    
    #opt.add_compute_class('smp16', 'cores', 16, max_tasks=50)
    #opt.add_compute_class('smp8', 'cores', 8, max_tasks=50)
    #opt.add_compute_class('smp4', 'cores', 4, max_tasks=50)
    
    opt.run()
    #with open('timing.log', 'w') as f:
    #    f.write(str(start) + ',' + str(time.time() - start))
