#!/usr/bin/python

"""
Some helper functions used for data cleaning
"""

import config as cfg
import pandas as pd
import numpy as np

from sklearn.preprocessing import LabelEncoder, OneHotEncoder, StandardScaler, MinMaxScaler, OrdinalEncoder
from sklearn.feature_extraction import DictVectorizer
from sklearn.metrics import roc_auc_score


__author__ = "Fredi Weideli"
__credits__ = ["Fredi Weideli"]
__version__ = "1.0.0"
__maintainer__ = "Fredi Weideli"
__email__ = "fredi.weideli@bluewin.ch"
__status__ = "Masterthesis-POC"


def save_model_history(history, path, file_format='json'):
    pdf = pd.DataFrame(history.history)

    if file_format == 'json':
        # save to json:
        hist_json_file = path + '.json'
        with open(hist_json_file, mode='w') as f:
            pdf.to_json(f)

    else:
        # save to csv:
        hist_csv_file = path + '.csv'
        with open(hist_csv_file, mode='w') as f:
            pdf.to_csv(f)


def config_pandas():
    pd.set_option('display.max_columns', None)
    pd.set_option('display.width', 300)


def clean_data(df):
    data = df[df["ido_type"] != "admin"]
    data = data[data["ido_type"] != "monitoring"]

    # find all columns having NaN
    nan_cols = data.columns[data.isna().any()].tolist()
    if nan_cols:
        found = ', '.join(nan_cols)
        print("columns with NaN: " + found)

        if 'loc_country_code' in nan_cols:
            data['loc_country_code'].fillna('NA', inplace=True)
            print("loc_country_code is fixed")

    # data = data.fillna('-')

    return data


def reduce_features(df, excluded_list=cfg.unused_feature_list):
    data = df.drop(labels=excluded_list, axis=1)
    return data


def shuffle_df(df, count=1, debug=False):
    data = df

    for i in range(0, count):
        if debug:
            print("shuffling data...")
        data = data.iloc[np.random.permutation(len(data))]

    return data


def build_label_based_df(df, label_value, sample_size=0):
    data = df[df[cfg.label_nr_col_name] == label_value]

    if sample_size > 0:
        data = data.sample(sample_size)

    return data


def build_anomaly_df(df, sample_size=0):
    return build_label_based_df(df, cfg.label_anomaly_idx, sample_size)


def build_normal_df(df, sample_size=0):
    return build_label_based_df(df, cfg.label_normal_idx, sample_size)


def build_suspect_df(df, sample_size=0):
    return build_label_based_df(df, cfg.label_suspect_idx, sample_size)


def append_label_index_column(df):
    df[cfg.label_index_col_name] = df[cfg.label_col_name].apply(lambda label_name: cfg.label_mapping_dict[label_name])


def convert_ido_id_column(df, new_col=True):
    if new_col:
        df[cfg.ido_id_present_col_name] = df[cfg.ido_id_col_name].apply(lambda ido_id: 0 if ido_id == '-' else 1)
    else:
        df[cfg.ido_id_col_name] = df[cfg.ido_id_col_name].apply(lambda ido_id: 'no' if ido_id == '-' else 'yes')


def copy_and_re_index(pandas_df):
    return pd.DataFrame(pandas_df.values, columns=pandas_df.columns, index=range(len(pandas_df)))


def create_pandas_data_frame(np_matrix, labels):
    df = pd.DataFrame(np_matrix)
    df.insert(0, 'label', labels)
    return df


def json_list_to_pandas_df(json_string_list):
    json_object_list = []
    for i in json_string_list:
        json_object_list.append(json.loads(i))
    return pd.DataFrame(json_object_list)


def build_normal_anomaly_sample_df(df, sample_size, exclude_list=None, shuffle=True, encode=True, debug=False, scale=False):

    data = df

    if debug:
        print("build data sets...")
    normal = data[data[cfg.label_nr_col_name] == cfg.label_normal_idx]
    anomaly = data[data[cfg.label_nr_col_name] == cfg.label_anomaly_idx]

    anomaly_rate = len(anomaly) / len(normal)
    anomaly_count = int(round(sample_size * anomaly_rate))

    data = pd.concat([normal.sample(sample_size - anomaly_count), anomaly.sample(anomaly_count)])

    if shuffle:
        data = shuffle_df(data, 3, debug)

    encoder_dict = {}

    if encode:
        if debug:
            print("encode dataframe...")
        encoder_dict = encode_categorical_columns(data, exclude_list, False, debug)

    if scale:
        if debug:
            print("scaling dataframe...")
        scale_columns_standard(data, exclude_list, debug)

    x_df = data.drop(labels=[cfg.label_nr_col_name], axis=1)
    y_df = data[cfg.label_nr_col_name]

    return x_df, y_df, anomaly_rate, encoder_dict


def build_normal_anomaly_balanced_sample_df(df, sample_size, exclude_list=None, shuffle=True, encode=True, debug=False, scale=False):

    data = df

    if debug:
        print("build data sets...")
    normal = data[data[cfg.label_nr_col_name] == cfg.label_normal_idx]
    anomaly = data[data[cfg.label_nr_col_name] == cfg.label_anomaly_idx]

    count = sample_size // 2

    data = pd.concat([normal.sample(count), anomaly.sample(count)])

    if shuffle:
        data = shuffle_df(data, 1, debug)

    encoder_dict = {}

    if encode:
        if debug:
            print("encode dataframe...")
        encoder_dict = encode_categorical_columns(data, exclude_list, False, debug)

    if scale:
        if debug:
            print("scaling dataframe...")
        scale_columns_standard(data, exclude_list, debug)

    x_df = data.drop(labels=[cfg.label_nr_col_name], axis=1)
    y_df = data[cfg.label_nr_col_name]

    return x_df, y_df, encoder_dict


def build_normal_anomaly_mixed_df(df, sample_size, exclude_list=None, shuffle=True, encode=True):

    data = df

    print("build data sets...")
    normal = data[data["label"] == 'normal']
    anomaly = data[data["label"] == 'anomaly']

    data = pd.concat([normal, anomaly])

    if shuffle:
        data = shuffle_df(data, 1)

    encoder_dict = {}

    if encode:
        print("encode dataframe...")
        encoder_dict = encode_categorical_columns(data, exclude_list)

    data = data[:sample_size]

    return data, encoder_dict


def build_normal_and_novelty_sample_df(df, training_count, validate_count, novelty_count, exclude_list=None, shuffle=True, encode=True, debug=False, scale=False):

    data = df
    count = novelty_count // 2

    if shuffle:
        data = shuffle_df(data, 1, debug)

    encoder_dict = {}

    if encode:
        if debug:
            print("encode dataframe...")
        encoder_dict = encode_categorical_columns(data, exclude_list, False, debug)

    if scale:
        if debug:
            print("scaling dataframe...")
        scale_columns_standard(data, exclude_list, debug)

    if debug:
        print("build data sets...")
    normal = data[data[cfg.label_nr_col_name] == cfg.label_normal_idx]
    anomaly = data[data[cfg.label_nr_col_name] == cfg.label_anomaly_idx]

    validation_end_index = training_count + validate_count

    train = normal[:training_count]
    validate = normal[training_count:validation_end_index]

    bad = anomaly[:count]
    good = normal[validation_end_index:(validation_end_index + count)]
    novelty = pd.concat([bad, good])

    x_df = train.drop(labels=[cfg.label_nr_col_name], axis=1)
    y_df = train[cfg.label_nr_col_name]

    x_val_df = validate.drop(labels=[cfg.label_nr_col_name], axis=1)
    y_val_df = validate[cfg.label_nr_col_name]

    x_nov_df = novelty.drop(labels=[cfg.label_nr_col_name], axis=1)
    y_nov_df = novelty[cfg.label_nr_col_name]

    return x_df, y_df, x_val_df, y_val_df, x_nov_df, y_nov_df, encoder_dict


def build_vectorized_normal_and_novelty_df(df, training_count, validate_count, novelty_count, exclude_list=None, sparse_vec=False, shuffle=True):

    data = df
    count = novelty_count // 2

    if shuffle:
        data = shuffle_df(data)

    print("re-index data...")
    data = copy_and_re_index(df)

    labels = data['label']
    #normal_idx = data[data["label"] == 'normal'].index
    #not_normal_idx = data[data["label"] != 'normal'].index

    if exclude_list:
        excludes = ', '.join(exclude_list)
        print("exclude: " + excludes)
        data = data.drop(labels=exclude_list, axis=1)

    print("vectorize dataframe...")
    encoded, vectorizer = one_hot_encode_with_vectorize_df(data, sparse_vec)

    print("create dataframe...")
    data = create_pandas_data_frame(encoded, labels)

    print("build data sets...")
    #normal = encoded[normal_idx, :]
    #not_normal = encoded[not_normal_idx, :]
    normal = data[data["label"] == 'normal']
    not_normal = data[data["label"] != 'normal']

    #free memory!
    encoded = None

    validation_end_index = training_count + validate_count

    train = normal[:training_count]
    validate = normal[training_count:validation_end_index]

    bad = not_normal[:count]
    good = normal[validation_end_index:(validation_end_index + count)]

    #novelty = np.concatenate((bad, good), axis=0)
    novelty = pd.concat([bad, good])

    print("all done!")

    return train, validate, novelty, vectorizer


def build_equally_distributed_df(df, sample_size, shuffle=True, encode=True):

    data = df
    count = sample_size // 2

    if shuffle:
        data = shuffle_df(data, 2)

    print("build data sets...")
    normal = data[data["label"] == 'normal']
    suspect = data[data["label"] == 'suspect']
    anomaly = data[data["label"] == 'anomaly']

    normal = normal[:count]

    if count > len(anomaly):
        data = suspect[:(count - len(anomaly))]
        data = pd.concat([data, anomaly])
    else:
        data = anomaly[:count]

    data = pd.concat([normal, data])

    if shuffle:
        data = shuffle_df(data, 2)

    encoder_dict = {}

    if encode:
        print("encode dataframe...")
        encoder_dict = encode_categorical_columns(data)

    return data, encoder_dict


def determine_unique_categories_per_feature(pandas_df, exclude_list=None):

    cols = pandas_df.columns.tolist()

    if exclude_list:
        for col in exclude_list:
            cols.remove(col)

    cat_dict = {}
    cat_values = []
    for col in cols:
        val = pandas_df[col].unique().tolist()
        cat_values.append(val)
        cat_dict[col] = val

    return cat_dict, cat_values


def create_column_list(df, exclude_list=None):
    cols = df.columns.tolist()

    if exclude_list:
        cols = list(set(cols) - set(exclude_list))

    return cols


def encode_categorical_columns(df, exclude_list=None, label_enc=False, debug=False):

    encoder_dict = {}

    for col in df.columns:
        if (df[col].dtype == "object") and (exclude_list is None or col not in exclude_list):
            if debug:
                print("encoding " + col)

            if label_enc:
                enc = LabelEncoder()
                col_val = df[col].values
            else:
                enc = OrdinalEncoder()
                col_val = df[col].values.reshape(-1, 1)

            enc.fit(col_val)

            encoder_dict[col] = enc

            df[col] = enc.transform(col_val)

    return encoder_dict


def scale_columns_standard(df, exclude_list=None, debug=False):

    cols = create_column_list(df, exclude_list)

    for col in cols:
        if debug:
            print("scaling " + col)
        df[col] = StandardScaler().fit_transform(df[col].values.reshape(-1, 1))

    return df


def one_hot_encode_columns(df, exclude_list=None):

    cols = create_column_list(df, exclude_list)

    for col in cols:
        print("encoding " + col)
        df[col] = OneHotEncoder(sparse=False).fit_transform(df[col].values.reshape(-1, 1))

    return df


def scale_columns_min_max(df, exclude_list=None):

    cols = create_column_list(df, exclude_list)

    for col in cols:
        #print("scaling " + col)
        df[col] = MinMaxScaler().fit_transform(df[col].values.reshape(-1, 1))

    return df


def calculate_accuracy_normal_df(normal_df, predictions):
    score = 0
    for i in range(0, normal_df.shape[0]):
        if predictions[i] == 1:
            score = score + 1

    accuracy = score / normal_df.shape[0]

    return accuracy


def calculate_accuracy_arbitrary_df(y_truth_df, predictions):

    labels = y_truth_df.values

    if len(labels) != len(predictions):
        return None

    score = 0
    for i in range(0, len(labels)):
        if predictions[i] == 1 and labels[i] == cfg.label_normal_idx:
            score = score + 1
        elif predictions[i] == -1 and labels[i] != cfg.label_normal_idx:
            score = score + 1

    accuracy = score / len(labels)

    return accuracy


def predict(sklearn_model, log_entries_pandas_df):

    pred = sklearn_model.predict(log_entries_pandas_df)
    return convert_predictions(pred)


def convert_predictions(sklearn_predictions, normal_val=1, bool_output=True):

    predictions = []
    for i in range(len(sklearn_predictions)):
        if sklearn_predictions[i] == normal_val:
            if bool_output:
                predictions.append(False)
            else:
                predictions.append(cfg.label_normal_idx)
        else:
            if bool_output:
                predictions.append(True)
            else:
                predictions.append(cfg.label_anomaly_idx)

    return predictions


def build_balanced_sample_df(df, sample_size=1000, shuffle=True, encode=True, scale=True, minmax=False, exclude_list=['label']):

    label_name = 'label_nr'

    exclude_from_enc = []

    normal = df[df[label_name] == 0]
    anomaly = df[df[label_name] == 1]
    suspect = df[df[label_name] == 2]

    count = sample_size // 2

    if sample_size <=40000:
        sample = pd.concat([normal.sample(count), anomaly.sample(count)])
    else:
        suspect_count = count -len(anomaly)
        #print("using additional suspect values: " + str(suspect_count))
        suspect_df = suspect.sample(suspect_count)
        suspect_df[label_name] = 1
        sample = pd.concat([normal.sample(count), anomaly, suspect_df])

    if shuffle:
        sample = shuffle_df(sample, 2)

    X_df = sample.drop(labels=exclude_list, axis=1)
    y_df = sample[label_name]

    if encode:
        encoder = encode_categorical_columns(X_df, exclude_from_enc)

    if scale:
        if minmax:
            scale_columns_min_max(X_df, exclude_from_enc)
        else:
            scale_columns_standard(X_df, exclude_from_enc)

    return X_df,y_df


def build_normal_anomaly_feature_selection_sample_df(df, sample_size=1000, shuffle=True, encode=True, scale=True, exclude_list=['label', 'label_nr']):

    label_name = 'label_nr'

    normal = df[df[label_name] == 0]
    anomaly = df[df[label_name] == 1]
    suspect = df[df[label_name] == 2]

    count = sample_size // 2

    if sample_size <=40000:
        sample = pd.concat([normal.sample(count), anomaly.sample(count)])
    else:
        suspect_count = count -len(anomaly)
        #print("using additional suspect values: " + str(suspect_count))
        suspect_df = suspect.sample(suspect_count)
        suspect_df['label_nr'] = 1
        sample = pd.concat([normal.sample(count), anomaly, suspect_df])

    if shuffle:
        sample = shuffle_df(sample, 2)

    X_df = sample.drop(labels=exclude_list, axis=1)
    y_df = sample[label_name]

    if encode:
        encoder = encode_categorical_columns(X_df)

    if scale:
        #du.scale_columns_standard(X_df)
        scale_columns_min_max(X_df)

    X = X_df.values
    y = y_df.values
    cols = X_df.columns.values

    return X,y,cols



########################################################
#  Encoding Functions
########################################################


def determine_categorical_cols_mask(pandas_df):
    # categorical boolean mask
    return pandas_df.dtypes == object


def determine_categorical_cols(pandas_df, categorical_col_mask, exclude_list=None):

    # filter categorical columns using mask and turn it into a list
    cat_cols = pandas_df.columns[categorical_col_mask].tolist()

    if exclude_list:
        cat_cols = [col for col in cat_cols if col not in exclude_list]

    return cat_cols


def encode_categorical_cols(pandas_df, categorical_columns):

    # instantiate label encoder object
    le = LabelEncoder()

    # apply le on categorical feature columns
    return pandas_df[categorical_columns].apply(lambda col: le.fit_transform(col))


def one_hot_encode(categorical_encoded_pandas_df, categorical_col_mask):
    # instantiate OneHotEncoder
    ohe = OneHotEncoder(categorical_features=categorical_col_mask, sparse=False)
    # categorical_features = boolean mask for categorical columns
    # sparse = False output an array not sparse matrix

    # apply OneHotEncoder on categorical feature columns
    # it returns an numpy array
    return ohe.fit_transform(categorical_encoded_pandas_df)


def one_hot_encode_df(pandas_df):
    mask = determine_categorical_cols_mask(pandas_df)
    cols = determine_categorical_cols(pandas_df, mask)
    labeled_df = encode_categorical_cols(pandas_df, cols)
    return one_hot_encode(labeled_df, mask)


def to_list_of_dictionaries(pandas_df):
    # turn each row as key-value pairs
    return pandas_df.to_dict(orient='records')


def vectorize(list_of_dictionaries, sparse_vec=False):
    # instantiate a Dictvectorizer object for dataframe
    # sparse = False makes the output is not a sparse matrix
    vectorizer = DictVectorizer(sparse=sparse_vec)

    # apply vectorizer on dictionaries
    encoded_array = vectorizer.fit_transform(list_of_dictionaries)

    return encoded_array, vectorizer


def one_hot_encode_with_vectorize_df(pandas_df, sparse_vec=False):
    return vectorize(to_list_of_dictionaries(pandas_df), sparse_vec)


def one_hot_encode_with_dummies_df(pandas_df):
    return pd.get_dummies(pandas_df, prefix_sep='_', drop_first=False)


def build_categories_list(x_df):
    cols = x_df.columns.tolist()
    categories = []
    for i in range(0, X.shape[1]):
        enc = encoder[cols[i]]
        categories.append(enc.categories_[0].tolist())

    return np.array(categories)


def one_hot_encode(x_df, y_df):

    X = x_df.values
    y = y_df.values

    X_1hot = None

    for i in range(0, X.shape[1]):
        #label_encoder = LabelEncoder()
        #feature = label_encoder.fit_transform(X[:,i])
        feature = X[:,i]
        feature = feature.reshape(X.shape[0], 1)
        onehot_encoder = OneHotEncoder(sparse=False, categories='auto')
        feature = onehot_encoder.fit_transform(feature)

        if X_1hot is None:
            X_1hot = feature
        else:
            X_1hot = np.concatenate((X_1hot, feature), axis=1)

    return X_1hot, y


########################################################
#  Metrics Functions
########################################################

def div(z, n):

    if z <= 0:
        return 0

    if n <= 0:
        return None

    return z / n


def calc_metrics(y_truth_list, y_prediction_list):

    z = zip(y_truth_list, y_prediction_list)

    a_count = 0
    n_count = 0
    t_pos = 0
    t_neg = 0
    f_pos = 0
    f_neg = 0

    for i, t in enumerate(z):
        val = t[0]
        pred = t[1]
        if val:  # anomaly
            a_count += 1
            if val == pred:
                t_pos += 1
            else:
                f_neg += 1
        else: # normal
            n_count += 1
            if val == pred:
                t_neg += 1
            else:
                f_pos += 1

    tot = i + 1
    tpr_recall = div(t_pos, (t_pos + f_neg))
    if tpr_recall is None:
        return None, None

    fnr = div(f_neg, (t_pos + f_neg))
    if fnr is None:
        return None, None

    tnr = div(t_neg, (t_neg + f_pos))
    if tnr is None:
        return None, None

    fpr = div(f_pos, (t_neg + f_pos))
    if fpr is None:
        return None, None

    precision = div(t_pos, (t_pos + f_pos))
    if precision is None:
        return None, None

    acc = div((t_pos + t_neg), tot)
    if acc is None:
        return None, None

    f1 = div((2 * precision * tpr_recall), (precision + tpr_recall))
    if f1 is None:
        return None, None

    values = []
    res = {'total': tot}
    values.append(tot)
    res['tot_anomaly'] = a_count
    values.append(a_count)
    res['tot_normal'] = n_count
    values.append(n_count)
    res['tpr_recall'] = tpr_recall
    values.append(tpr_recall)
    res['precision'] = precision
    values.append(precision)
    res['accuracy'] = acc
    values.append(acc)
    res['f1_score'] = f1
    values.append(f1)
    res['fnr'] = fnr
    values.append(fnr)
    res['tnr'] = tnr
    values.append(tnr)
    res['fpr'] = fpr
    values.append(fpr)
    res['conf_matrix'] = [[t_pos, f_pos], [f_neg, t_neg]]
    values.append(t_pos)
    values.append(f_pos)
    values.append(f_neg)
    values.append(t_neg)
    auc = roc_auc_score(y_truth_list, y_prediction_list)
    res['auc'] = auc
    values.append(auc)

    return res, values


def calc_best_threshold(y_truth_list, y_scores, step=0.005, debug=False):

    fpr = []
    tpr = []
    auc = 0
    thres_auc = 0
    f1 = 0
    thres_f1 = 0

    threshold = min(y_scores) + step
    while threshold <= max(y_scores):

        y_prediction_list = y_scores < threshold

        res, tmp = calc_metrics(y_truth_list, y_prediction_list)
        if res:
            fpr.append(res['fpr'])
            tpr.append(res['tpr_recall'])

            tmp = res['auc']
            if tmp > auc:
                auc = tmp
                thres_auc = threshold

            tmp = res['f1_score']
            if tmp > f1:
                f1 = tmp
                thres_f1 = threshold
        else:
            if debug:
                print("calc_best_threshold: calc_metrics returned None")

        threshold += step

    values = []
    res_dict = {'best_auc': auc}
    values.append(auc)
    res_dict['best_auc_threshold'] = thres_auc
    values.append(thres_auc)
    res_dict['best_f1_score'] = f1
    values.append(f1)
    res_dict['best_f1_score_threshold'] = thres_f1
    values.append(thres_f1)

    return res_dict, fpr, tpr, values


metrics_columns = ['best_auc','best_auc_threshold','best_f1_score','best_f1_score_threshold',
                   '_total','_tot_anomaly','_tot_normal','_tpr_recall','_precision','_accuracy','_f1_score','_fnr','_tnr','_fpr','_t_pos','_f_pos','_f_neg','_t_neg','_auc',
                   'total','tot_anomaly','tot_normal','tpr_recall','precision','accuracy','f1_score','fnr','tnr','fpr','t_pos','f_pos','f_neg','t_neg','auc',
                   'time_to_fit'
                   ]

unused_metrics_columns = ['best_auc','best_auc_threshold','best_f1_score','_total','_tot_anomaly','_tot_normal','_tpr_recall','_precision',
                          '_accuracy','_f1_score','_fnr','_tnr','_fpr','_t_pos','_f_pos','_f_neg','_t_neg','_auc']


def create_metric_df(metrics_list, path_to_save):
    metrics_df = pd.DataFrame(metrics_list, columns=metrics_columns)
    export_csv = metrics_df.to_csv(path_to_save, index=None, header=True)
    df = metrics_df.drop(labels=unused_metrics_columns, axis=1)
    return df


def step(scores, num_of_steps=200):
    return (max(scores) - min(scores)) / num_of_steps


sentiment_metrics_columns = ['total','tpr_recall','precision','accuracy','f1_score','t_pos','f_pos','f_neg','t_neg','auc','time_to_fit']


def create_sentiment_metric_df(metrics_list, path_to_save):
    metrics_df = pd.DataFrame(metrics_list, columns=sentiment_metrics_columns)
    export_csv = metrics_df.to_csv(path_to_save, index=None, header=True)
    return metrics_df


autoencoder_selection_metrics_columns = ['loss_s1','mae_s1','acc_s1','loss_s2','mae_s2','acc_s2','loss_d1','mae_d1','acc_d1','loss_d2','mae_d2','acc_d2']


def create_autoencoder_selection_metric_df(metrics_list, path_to_save):
    metrics_df = pd.DataFrame(metrics_list, columns=autoencoder_selection_metrics_columns)
    export_csv = metrics_df.to_csv(path_to_save, index=None, header=True)
    return metrics_df


autoencoder_metrics_columns = ['total','threshold','tpr_recall','precision','accuracy','f1_score','t_pos','f_pos','f_neg','t_neg','auc','time_to_fit']


def create_autoencoder_metric_df(metrics_list, path_to_save):
    metrics_df = pd.DataFrame(metrics_list, columns=autoencoder_metrics_columns)
    export_csv = metrics_df.to_csv(path_to_save, index=None, header=True)
    return metrics_df

