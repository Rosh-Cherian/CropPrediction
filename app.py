from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle  # or pickle, depending on how you saved your model
import numpy as np

app = Flask(__name__)
#CORS(app)
CORS(app, resources={r"/*": {"origins": "*"}})
# Load the Machine Learning Model
feature_names = ['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']
model = pickle.load(open('Crop_recommendation.sav','rb'))  # Replace with your model's filename
label_encoder = pickle.load(open('LabelEncoder.sav', 'rb'))

@app.route('/predict', methods=['POST'])
def predict():
    try:
        print("hey")
        # Extract data from POST request
        data = request.json  # Expecting a JSON payload
        print('data:',data)

        # Extract input features based on predefined feature names
        input_data = [data[feature] for feature in feature_names]
        print('input data: ',input_data)

        # Convert input data to a 2D numpy array (1 sample with len(feature_names) features)
        input_data = np.array(input_data).reshape(1, -1)  # Ensure shape is (1, num_features)
        print('input data: ',input_data)
        # Make prediction
        prediction = model.predict(input_data)
        print(prediction[0])
        prediction_labels = label_encoder.inverse_transform(prediction)
        return jsonify({'prediction': prediction_labels[0]})  # Send prediction as a response
    except Exception as e:
        return jsonify({'error': str(e)})
    
@app.route('/test', methods=['GET', 'POST'])
def test():
    return jsonify({"message": "Test successful"})
if __name__ == '__main__':
    #app.run(debug=True)
    app.run(host='0.0.0.0', port=5001)