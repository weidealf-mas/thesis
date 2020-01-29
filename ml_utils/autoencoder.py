import config as cfg
import numpy as np

from keras import regularizers
from keras.models import Model
from keras.layers import Dense, Input
from keras.optimizers import RMSprop
from sklearn.metrics import classification_report


def create_simple_auto_encoder(input_dim, encoding_dim, activation='relu'):
    input_array = Input(shape=(input_dim,))
    encoded = Dense(encoding_dim, activation=activation)(input_array)
    decoded = Dense(input_dim, activation='softmax')(encoded)
    return Model(input_array, decoded)


def create_sparse_auto_encoder(input_dim, encoding_dim, activation='relu', regularizer=regularizers.l1(10e-5)):
    input_array = Input(shape=(input_dim,))
    encoded = Dense(encoding_dim, activation=activation, activity_regularizer=regularizer)(input_array)
    decoded = Dense(input_dim, activation='softmax')(encoded)
    return Model(input_array, decoded)


def create_deep_auto_encoder(input_dim, encoding_dim_1, encoding_dim_2, encoding_dim_3, activation='relu'):
    input_array = Input(shape=(input_dim,))
    encoded = Dense(encoding_dim_1, activation=activation)(input_array)
    encoded = Dense(encoding_dim_2, activation=activation)(encoded)
    encoded = Dense(encoding_dim_3, activation=activation)(encoded)

    decoded = Dense(encoding_dim_2, activation=activation)(encoded)
    decoded = Dense(encoding_dim_1, activation=activation)(decoded)
    decoded = Dense(input_dim, activation='softmax')(decoded)

    return Model(input_array, decoded)


def create_deep_auto_encoder_2(input_dim, encoding_dim_1, encoding_dim_2, activation='relu', regularizer=regularizers.l1(10e-5)):
    input_array = Input(shape=(input_dim,))
    encoded = Dense(encoding_dim_1, activation=activation, activity_regularizer=regularizer)(input_array)
    encoded = Dense(encoding_dim_2, activation=activation, activity_regularizer=regularizer)(encoded)

    decoded = Dense(encoding_dim_1, activation=activation)(encoded)
    decoded = Dense(input_dim, activation='softmax')(decoded)

    return Model(input_array, decoded)


def auto_encoder_fit(model, x_train, x_test, optimizer='RMSprop', epochs=25, batch_size=32):
    model.compile(optimizer=optimizer, loss='mean_squared_error', metrics=['mae', 'accuracy'])
    history = model.fit(x_train, x_train,
                        batch_size=batch_size,
                        epochs=epochs,
                        verbose=1,
                        shuffle=True,
                        validation_data=(x_test, x_test))

    return history


def classify(true_values, predicted_values, threshold=10):

    y_error = np.linalg.norm(true_values - predicted_values, axis=-1)
    z = zip(y_error >= threshold, y_error)

    y_class = []
    error = []
    for idx, (is_anomaly, y_error) in enumerate(z):
        if is_anomaly:
            y_class.append(cfg.label_anomaly_idx)
        else:
            y_class.append(cfg.label_normal_idx)

        error.append(y_error)

    return y_class, error


def calc_metrics(x_values, y_label, y_pred, label='1'):
    threshold = 0
    f1_max = 0
    thres = 0

    while threshold < 20:

        y_class, errors = classify(x_values, y_pred, threshold)
        report = classification_report(y_label, y_class, output_dict=True)
        f1 = report[label]['f1-score']

        if f1 > f1_max:
            f1_max = f1
            p = report[label]['precision']
            r = report[label]['recall']
            sup = report[label]['support']
            acc = report['accuracy']
            thres = threshold

        threshold += 0.1

    return thres, f1_max, p, r, sup, acc


