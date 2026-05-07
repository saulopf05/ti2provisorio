package model;

import java.util.ArrayList;
import java.util.List;

public class PcSpecs {
    private final List<DetectedComponent> components = new ArrayList<>();
    private String rawText;
    private String cpuSocket;
    private String ramType;
    private Integer psuWatts;

    public List<DetectedComponent> getComponents() { return components; }
    public String getRawText() { return rawText; }
    public void setRawText(String rawText) { this.rawText = rawText; }
    public String getCpuSocket() { return cpuSocket; }
    public void setCpuSocket(String cpuSocket) { this.cpuSocket = cpuSocket; }
    public String getRamType() { return ramType; }
    public void setRamType(String ramType) { this.ramType = ramType; }
    public Integer getPsuWatts() { return psuWatts; }
    public void setPsuWatts(Integer psuWatts) { this.psuWatts = psuWatts; }

    public DetectedComponent find(String type) {
        for (DetectedComponent c : components) {
            if (c.getType().equalsIgnoreCase(type)) return c;
        }
        return null;
    }
}
