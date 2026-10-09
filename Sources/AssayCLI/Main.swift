import App

@main
struct Main {
    static func main() async {
        await configure(app)
        await AssayCLI.main()
    }
}
