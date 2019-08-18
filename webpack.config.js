const path = require('path');

//In the future we can install a plugin provided by webpack to automatically uglify javascript files on build
module.exports = {
    entry: {
        documentviewer: './Assets/js/es6/external/document_viewer/documentviewer.js' 
    },  
    output: {
        path: path.resolve(__dirname, './Scripts/build'),
        filename: '[name].bundle.js'
    },
    mode: 'development',
    module: {
        rules: [{
            loader: 'babel-loader',
            test: /\.js$/,
            exclude: /node_modules/
        }]
    }
};