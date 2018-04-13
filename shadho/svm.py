import shadho_worker

import json
import os
import time

from sklearn.svm import SVC
from sklearn.ensemble import BaggingClassifier
from sklearn.multiclass import OneVsRestClassifier
from sklearn.metrics import accuracy_score, precision_score, \
                            recall_score, roc_auc_score, log_loss

import numpy as np

LABELS = [[0 for i in range(10)] for j in range(10)]
for i in range(len(LABELS)):
    LABELS[i][i] = 1

def load_data():
    data = np.load('mnist.npz')
    X_train = data['x_train']
    y_train = data['y_train']
    X_test = data['x_test']
    y_test = data['y_test']
    data.close()
    shapes = X_train.shape
    X_train = X_train.reshape(shapes[0], shapes[1] * shapes[2])
    shapes = X_test.shape
    X_test = X_test.reshape(shapes[0], shapes[1] * shapes[2])
    return (X_train, y_train), (X_test, y_test)


def main(svm):
    svm = svm[list(svm.keys())[0]]
    (X_train, y_train), (X_test, y_test) = load_data()

    start = time.time()

    X_train = X_train.astype(np.float32) / 255.0
    X_test = X_test.astype(np.float32) / 255.0

    s = OneVsRestClassifier(BaggingClassifier(SVC(**svm), n_estimators=10, max_samples=0.1, n_jobs=-1))
    s.fit(X_train, y_train)
    predictions = s.predict(X_test)

    loss_labels = [LABELS[i] for i in predictions]
    loss = log_loss(y_test, loss_labels, labels=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    acc = accuracy_score(y_test, predictions)
    p = precision_score(y_test, predictions, average='micro')
    r = recall_score(y_test, predictions, average='micro')

    out = {
        'loss': loss,
        'accuracy': acc,
        'precision': p,
        'recall': r,
        'params': svm,
        'host': os.uname()[1],
        'running_time': time.time() - start
    }

    return out


if __name__ == '__main__':
    shadho_worker.run(main)
