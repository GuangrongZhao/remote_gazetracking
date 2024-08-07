import h5py
import numpy as np
import torch
import torch.utils.data as Data
from tqdm import tqdm
import os
import sys
import argparse

sys.path.append("..")

from model import DilatedNet

if __name__ == "__main__":
    def pitchyaw_to_vector(pitchyaws):
        n = pitchyaws.shape[0]
        sin = np.sin(pitchyaws)
        cos = np.cos(pitchyaws)
        out = np.empty((n, 3))
        out[:, 0] = np.multiply(cos[:, 0], sin[:, 1])
        out[:, 1] = sin[:, 0]
        out[:, 2] = np.multiply(cos[:, 0], cos[:, 1])
        return out

    def vector_to_pitchyaw(vectors):
        n = vectors.shape[0]
        out = np.empty((n, 2))
        vectors = np.divide(vectors, np.linalg.norm(vectors, axis=1).reshape(n, 1))
        out[:, 0] = np.arcsin(vectors[:, 1])  # theta
        out[:, 1] = np.arctan2(vectors[:, 0], vectors[:, 2])  # phi
        return out

    def angular_error(a, b):
        a = pitchyaw_to_vector(a) if a.shape[1] == 2 else a
        b = pitchyaw_to_vector(b) if b.shape[1] == 2 else b
        ab = np.sum(np.multiply(a, b), axis=1)
        a_norm = np.linalg.norm(a, axis=1)
        b_norm = np.linalg.norm(b, axis=1)
        a_norm = np.clip(a_norm, a_min=1e-7, a_max=None)
        b_norm = np.clip(b_norm, a_min=1e-7, a_max=None)
        similarity = np.divide(ab, np.multiply(a_norm, b_norm))
        return np.arccos(similarity) * 180.0 / np.pi

    np.random.seed(1337)
    torch.manual_seed(1337)
    torch.cuda.manual_seed_all(1337)
    parser = argparse.ArgumentParser()
    parser.add_argument("--cuda", default="0", help="The GPU ID")
    parser.add_argument("--epoch", default=80, type=int, help="The number of epochs")
    parser.add_argument("--network", default="DilatedNet", help="The type of network")
    parser.add_argument("--data_path", default="G:/remote_apperance_gaze_dataset/processed_data/data_network_training_for_frame_method_eva/",
                        help="Path to the dataset")
    parser.add_argument("--model_save_path", default="G:/remote_apperance_gaze_dataset/processed_data/pre_trained_models_for_frame_method_eva/checkpoints",
                        help="Path to save the model checkpoints")

    args = parser.parse_args()

    device = torch.device("cuda:" + args.cuda if torch.cuda.is_available() else "cpu")
    print(device)

    #################################### Configure data loader#################################################

    train_start = 1
    train_end = 34

    test_start = 34
    test_end = 67
    train_data = []
    train_label = []
    train_head = []
    flag = 1

    for ii in range(train_start, train_end):
        for jj in [1, 2, 3, 4, 5, 6]:
            f_data = h5py.File(os.path.join(args.data_path,
                                            f"64_96_L_eye_normalized_user_{ii}_exp{jj}.h5"), 'r')
            f_label = h5py.File(os.path.join(args.data_path,
                                             f"L_pitch_yaw_user_{ii}_exp{jj}.h5"), 'r')
            f_head = h5py.File(os.path.join(args.data_path,
                                            f"L_headpose_user_{ii}_exp{jj}.h5"), 'r')

            train_data_temp = ((f_data['data'][()]).T).reshape(-1, 1, 64, 96)
            train_label_temp = ((f_label['data'][()]).T)
            train_head_temp = ((f_head['data'][()]).T)
            if flag == 1:
                train_data = train_data_temp
                train_label = train_label_temp
                train_head = train_head_temp
                flag = flag + 1
            else:
                train_data = np.concatenate((train_data, train_data_temp), axis=0)
                train_label = np.concatenate((train_label, train_label_temp), axis=0)
                train_head = np.concatenate((train_head, train_head_temp), axis=0)

    print(train_data.shape)
    print(train_label.shape)
    print(train_head.shape)

    trainDataset = Data.TensorDataset((torch.from_numpy(train_data).type(torch.FloatTensor) / 255),
                                      (torch.from_numpy(train_label).type(torch.FloatTensor)),
                                      (torch.from_numpy(train_head).type(torch.FloatTensor)))

    n_train = len(trainDataset)

    trainloader = torch.utils.data.DataLoader(
        trainDataset,
        batch_size=256,
        shuffle=True,
        num_workers=4,
    )

    ####################################### #########################################################################################################

    test_data = []
    test_label = []
    test_head = []
    flag = 1

    for ii in range(test_start, test_end):
        for jj in [1, 2, 3, 4, 5, 6]:
            f_data = h5py.File(os.path.join(args.data_path,
                                            f"64_96_L_eye_normalized_user_{ii}_exp{jj}.h5"), 'r')
            f_label = h5py.File(os.path.join(args.data_path,
                                             f"L_pitch_yaw_user_{ii}_exp{jj}.h5"), 'r')
            f_head = h5py.File(os.path.join(args.data_path,
                                            f"L_headpose_user_{ii}_exp{jj}.h5"), 'r')

            test_data_temp = ((f_data['data'][()]).T).reshape(-1, 1, 64, 96)
            test_label_temp = ((f_label['data'][()]).T)
            test_head_temp = ((f_head['data'][()]).T)
            if flag == 1:
                test_data = test_data_temp
                test_label = test_label_temp
                test_head = test_head_temp
                flag = flag + 1
            else:
                test_data = np.concatenate((test_data, test_data_temp), axis=0)
                test_label = np.concatenate((test_label, test_label_temp), axis=0)
                test_head = np.concatenate((test_head, test_head_temp), axis=0)

    print(test_data.shape)
    print(test_label.shape)
    print(test_head.shape)

    testDataset = Data.TensorDataset((torch.from_numpy(test_data).type(torch.FloatTensor) / 255),
                                     torch.from_numpy(test_label).type(torch.FloatTensor),
                                     torch.from_numpy(test_head).type(torch.FloatTensor))
    n_val = len(testDataset)
    testloader = torch.utils.data.DataLoader(
        testDataset,
        batch_size=512,
        shuffle=False,
        num_workers=8,
    )
    #################################### Configure data loader#################################################

    if args.network == "DilatedNet":
        model = DilatedNet.DilatedNet().to(device)
        optimizer = torch.optim.Adam(model.parameters(), lr=0.001, betas=(0.9, 0.95))
        scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=8000, gamma=0.1)

    print(model)
    length = len(trainloader)

    os.makedirs(args.model_save_path, exist_ok=True)

    with open(os.path.join(args.model_save_path, "dilated_L_eye"), 'w') as outfile:
        for epoch in tqdm(range(args.epoch)):

            for i, data in enumerate(tqdm(trainloader, desc="Batches", leave=False)):
                model.train()
                x, labels, head = data
                x, labels, head = x.to(device), labels.to(device), head.to(device)

                pixel_preds = model(x, head)

                loss = torch.nn.MSELoss(reduction='mean')(pixel_preds, labels)
                optimizer.zero_grad()
                loss.backward()
                optimizer.step()
                scheduler.step()
            print(loss)

            with torch.no_grad():
                model.eval()
                Testloss = 0
                Testlosstotal = 0
                Testdistance = 0

                for data in tqdm(testloader, desc="Testing Batches", leave=False):
                    inputs, labels, head = data
                    inputs, labels, head = inputs.to(device), labels.to(device), head.to(device)
                    label = model(inputs, head)
                    Testloss += torch.nn.MSELoss(reduction='mean')(label, labels)
                    output = angular_error((label.cpu().detach().numpy()), (labels.cpu().numpy()))
                    Testdistance += np.mean(output)
                    Testlosstotal += 1

                log = f"[{epoch}/{args.epoch}]: loss:{Testloss / Testlosstotal} distance:{Testdistance / Testlosstotal}"
                print(log)
                outfile.write(log + "\n")
                sys.stdout.flush()
                outfile.flush()

            if epoch % 10 == 0:
                torch.save(model.state_dict(), os.path.join(args.model_save_path,
                                                            f"dilated_L_eye_Iter_{epoch}.pt"))
