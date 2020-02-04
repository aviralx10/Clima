

import Foundation
import CoreLocation
protocol  WeatherManagerDelegate {
    func didUpdateWeather(_ weathermanagar: weathermanager , weather :WeatherModel)
    func didFailWithError(error: Error)
}
struct weathermanager{
    let weatherURL="https://api.openweathermap.org/data/2.5/weather?appid=cc2b6e82c2ed70e0368a49dd1f8c7458&units=metric"
    var delegate : WeatherManagerDelegate?
    func fetchweather(cityName:String){
        let URLstring="\(weatherURL)&q=\(cityName)"
        performRequest(with  : URLstring)
    }
    func fetchweather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let URLstring="\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with  : URLstring)
    }
    func performRequest(with urlString:String){
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? " "){
            let session=URLSession(configuration: .default)
            let task=session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error! )
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather:weather)
                        }
                    }
                }
            task.resume()
        }
    }
    func parseJSON(_ weatherData: Data)-> WeatherModel?{
        let decoder=JSONDecoder()
        do{
            let decodedData=try decoder.decode(WeatherData.self, from: weatherData)
            let id = (decodedData.weather[0].id)
            let temp = decodedData.main.temp
            let cityName = decodedData.name
            let weather = WeatherModel(conditionId: id,cityName: cityName,temperature: temp)
            return weather
        } catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
        
        
    }
    
}
