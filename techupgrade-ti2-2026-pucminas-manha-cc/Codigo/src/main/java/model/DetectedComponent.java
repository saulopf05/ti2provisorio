package model;

public class DetectedComponent {
    private String type;
    private String value;
    private Component matchedComponent;

    public DetectedComponent(String type, String value) {
        this.type = type;
        this.value = value;
    }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
    public Component getMatchedComponent() { return matchedComponent; }
    public void setMatchedComponent(Component matchedComponent) { this.matchedComponent = matchedComponent; }
}
