package model;

import java.math.BigDecimal;

public class Component {
    private long id;
    private String type;
    private String brand;
    private String model;
    private String socket;
    private String ramType;
    private BigDecimal capacityGb;
    private BigDecimal vramGb;
    private Integer tdpWatts;
    private BigDecimal benchmarkScore;
    private BigDecimal price;
    private Integer wattage;
    private String interfaceType;
    private String url;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }
    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }
    public String getSocket() { return socket; }
    public void setSocket(String socket) { this.socket = socket; }
    public String getRamType() { return ramType; }
    public void setRamType(String ramType) { this.ramType = ramType; }
    public BigDecimal getCapacityGb() { return capacityGb; }
    public void setCapacityGb(BigDecimal capacityGb) { this.capacityGb = capacityGb; }
    public BigDecimal getVramGb() { return vramGb; }
    public void setVramGb(BigDecimal vramGb) { this.vramGb = vramGb; }
    public Integer getTdpWatts() { return tdpWatts; }
    public void setTdpWatts(Integer tdpWatts) { this.tdpWatts = tdpWatts; }
    public BigDecimal getBenchmarkScore() { return benchmarkScore; }
    public void setBenchmarkScore(BigDecimal benchmarkScore) { this.benchmarkScore = benchmarkScore; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public Integer getWattage() { return wattage; }
    public void setWattage(Integer wattage) { this.wattage = wattage; }
    public String getInterfaceType() { return interfaceType; }
    public void setInterfaceType(String interfaceType) { this.interfaceType = interfaceType; }
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
}
